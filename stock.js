// ==========================================================
//  SHREE SAWRIYA SOLUTIONS - STOCK MANAGEMENT (Supabase)
//  Login wahi hai jo Sale Register / Repairs page ka hai.
//  Staff: stock search kar sakta hai aur naya stock add kar sakta hai.
//  Admin: upar ka sab + qty -/+, history, edit, delete, CSV.
// ==========================================================

const SUPABASE_URL = 'https://bwldelmfkcynfvbqcneb.supabase.co';
const SUPABASE_KEY = 'sb_publishable_GKmljKQOjWzJ54FdZVPk_g_auEFS9VG';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// ---------- Helpers ----------
function $(id) { return document.getElementById(id); }

function esc(s) {
  return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
  });
}

function todayStr() {
  const d = new Date();
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}

function fmtDate(s) {
  if (!s) return '';
  const p = String(s).slice(0, 10).split('-');
  return p.length === 3 ? p[2] + '/' + p[1] + '/' + p[0] : s;
}

function fmtDateTime(s) {
  return new Date(s).toLocaleString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function money(n) {
  return '₹' + Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 });
}

function norm(s) { return String(s || '').trim().toLowerCase().replace(/\s+/g, ' '); }
function clean(s) { const v = String(s || '').trim().replace(/\s+/g, ' '); return v === '' ? null : v; }
function numOrNull(v) { return v === '' || v == null ? null : Number(v); }

let toastTimer = null;
function toast(msg, type) {
  const t = $('toast');
  t.textContent = msg;
  t.className = 'toast ' + (type === 'err' ? 'err' : 'ok');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(function () { t.classList.add('hidden'); }, 3500);
}

function errorMessage(error) {
  const m = ((error && error.message) || '').toLowerCase();
  const code = error && error.code;
  if (m.includes('fetch') || m.includes('network') || m.includes('failed to')) {
    return 'Internet connection check karo, data save nahi hua.';
  }
  if (m.includes('itna stock nahi')) return 'Itna stock nahi hai.';
  if (code === '42501' || m.includes('row-level security') || m.includes('permission')) {
    return 'Aapko ye karne ki permission nahi hai.';
  }
  return 'Kuch gadbad hui. Dobara try karo.';
}

// ---------- State ----------
let profile = null;
let loginRole = 'staff';
let isAdmin = false;
let items = [];
let catFilter = '';
let statFilter = 'all';     // all | low | out
let qtyMode = null;         // { id, sign }

const REASONS_MINUS = ['Used in repair', 'Sale', 'Return', 'Adjust'];
const REASONS_PLUS = ['Purchase', 'Return', 'Adjust'];

function status(it) {
  if (it.quantity <= 0) return 'out';
  if (it.min_quantity > 0 && it.quantity <= it.min_quantity) return 'low';
  return 'ok';
}

function displayName() {
  const n = (profile && profile.full_name) || '';
  return n.indexOf('@') !== -1 ? n.split('@')[0] : (n || null);
}

function itemLabel(it) {
  return [it.product_name, it.brand, it.model].filter(Boolean).join(' · ');
}

// ==========================================================
//  LOGIN / LOGOUT
// ==========================================================
$('tabStaff').addEventListener('click', function () { setLoginTab('staff'); });
$('tabAdmin').addEventListener('click', function () { setLoginTab('admin'); });

function setLoginTab(role) {
  loginRole = role;
  $('tabStaff').classList.toggle('active', role === 'staff');
  $('tabAdmin').classList.toggle('active', role === 'admin');
}

$('loginForm').addEventListener('submit', async function (e) {
  e.preventDefault();
  const email = $('loginEmail').value.trim();
  const password = $('loginPassword').value;
  if (!email || !password) { toast('Email aur password daalo.', 'err'); return; }

  $('loginBtn').disabled = true;
  const { data, error } = await db.auth.signInWithPassword({ email: email, password: password });
  $('loginBtn').disabled = false;

  if (error) {
    const m = (error.message || '').toLowerCase();
    toast(m.includes('fetch') || m.includes('network') ? 'Internet connection check karo.' : 'Login nahi hua. Email/password check karo.', 'err');
    return;
  }

  const ok = await loadProfile(data.user.id);
  if (!ok || (loginRole === 'admin' && profile.role !== 'admin')) {
    await db.auth.signOut();
    profile = null;
    toast('Aapko ye karne ki permission nahi hai.', 'err');
    return;
  }

  $('loginPassword').value = '';
  showApp();
});

$('logoutBtn').addEventListener('click', async function () {
  await db.auth.signOut();
  profile = null;
  items = [];
  $('appView').classList.add('hidden');
  $('loginView').classList.remove('hidden');
});

async function loadProfile(userId) {
  const { data, error } = await db.from('profiles').select('role, can_view, full_name').eq('id', userId).maybeSingle();
  if (error || !data) return false;
  profile = data;
  return true;
}

function showApp() {
  isAdmin = profile.role === 'admin';
  $('loginView').classList.add('hidden');
  $('appView').classList.remove('hidden');

  const badge = $('modeBadge');
  badge.textContent = isAdmin ? 'ADMIN MODE' : 'STAFF MODE';
  badge.className = 'badge ' + (isAdmin ? 'admin' : 'staff');
  $('whoText').textContent = displayName() || '';
  $('exportBtn').classList.toggle('hidden', !isAdmin);
  $('fDate').value = todayStr();

  loadStock();
}

// ==========================================================
//  LOAD + RENDER
// ==========================================================
async function loadStock() {
  const { data, error } = await db
    .from('stock_items')
    .select('*')
    .order('product_name', { ascending: true })
    .order('brand', { ascending: true })
    .order('model', { ascending: true })
    .limit(5000);
  if (error) {
    $('stockList').innerHTML = '<div class="empty">' + esc(errorMessage(error)) + '</div>';
    return;
  }
  items = data || [];
  fillDatalists();
  render();
}

function fillDatalists() {
  function fill(id, key) {
    const seen = {};
    const out = [];
    items.forEach(function (it) {
      const v = it[key];
      if (v && !seen[norm(v)]) { seen[norm(v)] = 1; out.push(v); }
    });
    out.sort(function (a, b) { return a.localeCompare(b); });
    $(id).innerHTML = out.map(function (v) { return '<option value="' + esc(v) + '">'; }).join('');
  }
  fill('dlProducts', 'product_name');
  fill('dlBrands', 'brand');
  fill('dlSuppliers', 'supplier');
}

function filtered() {
  const q = norm($('searchBox').value);
  return items.filter(function (it) {
    if (catFilter && it.category !== catFilter) return false;
    if (statFilter !== 'all' && status(it) !== statFilter) return false;
    if (!q) return true;
    const hay = norm([it.product_name, it.brand, it.model, it.supplier, it.notes].join(' '));
    return q.split(' ').every(function (w) { return hay.indexOf(w) !== -1; });
  });
}

function render() {
  // Totals (poore stock ke)
  let pcs = 0, low = 0, out = 0;
  items.forEach(function (it) {
    pcs += it.quantity;
    const s = status(it);
    if (s === 'low') low++;
    if (s === 'out') out++;
  });
  $('totItems').textContent = items.length;
  $('totPcs').textContent = pcs;
  $('totLow').textContent = low;
  $('totOut').textContent = out;
  document.querySelectorAll('.t-btn').forEach(function (b) {
    b.classList.toggle('active', statFilter !== 'all' && b.getAttribute('data-stat') === statFilter);
  });

  const list = filtered();
  const fpcs = list.reduce(function (s, it) { return s + it.quantity; }, 0);
  $('countLabel').textContent = list.length + ' items · ' + fpcs + ' pieces' +
    (statFilter === 'low' ? ' · sirf kam stock' : statFilter === 'out' ? ' · sirf khatam' : '');

  if (list.length === 0) {
    $('stockList').innerHTML = '<div class="empty">' + (items.length ? 'Kuch nahi mila.' : 'Abhi koi stock nahi hai. Upar se pehla item add karo.') + '</div>';
    return;
  }

  // Product name ke hisaab se group
  const groups = [];
  const byName = {};
  list.forEach(function (it) {
    const k = norm(it.product_name);
    if (!byName[k]) { byName[k] = { name: it.product_name, rows: [], pcs: 0 }; groups.push(byName[k]); }
    byName[k].rows.push(it);
    byName[k].pcs += it.quantity;
  });

  let html = '';
  groups.forEach(function (g) {
    html += '<div class="item-group">' + esc(g.name) + '<span>' + g.rows.length + ' items · ' + g.pcs + ' pcs</span></div>';
    g.rows.forEach(function (it) {
      const s = status(it);
      const qtyText = it.quantity > 0 ? it.quantity + ' pcs' : 'Khatam';
      const meta = [];
      if (it.supplier) meta.push(esc(it.supplier));
      if (it.purchase_price != null) meta.push('Khareed ' + money(it.purchase_price));
      if (it.selling_price != null) meta.push('Bikri ' + money(it.selling_price));
      if (it.entry_date) meta.push(fmtDate(it.entry_date));
      if (it.updated_by_name) meta.push('by ' + esc(it.updated_by_name));

      html += '<div class="item">' +
        '<div class="item-head">' +
          '<div class="item-title">' + esc([it.brand, it.model].filter(Boolean).join(' ') || it.product_name) +
            '<small>' + esc(it.category) + '</small></div>' +
          '<span class="qty ' + s + '">' + qtyText + '</span>' +
        '</div>' +
        (meta.length ? '<div class="item-meta">' + meta.join(' · ') + '</div>' : '') +
        (it.notes ? '<div class="item-note">' + esc(it.notes) + '</div>' : '') +
        // Staff ko sirf search + naya stock add; baaki buttons sirf Admin ke liye
        (isAdmin ? '<div class="item-actions">' +
          '<button type="button" class="btn btn-use" data-act="minus" data-id="' + it.id + '"' + (it.quantity <= 0 ? ' disabled' : '') + '>− Use</button>' +
          '<button type="button" class="btn btn-add" data-act="plus" data-id="' + it.id + '">+ Add</button>' +
          '<button type="button" class="btn btn-ghost" data-act="hist" data-id="' + it.id + '">History</button>' +
          '<button type="button" class="btn btn-edit" data-act="edit" data-id="' + it.id + '">Edit</button>' +
          '<button type="button" class="btn btn-del" data-act="del" data-id="' + it.id + '">Delete</button>' +
        '</div>' : '') +
      '</div>';
    });
  });
  $('stockList').innerHTML = html;
}

$('searchBox').addEventListener('input', render);

document.querySelectorAll('#catFilters .filter-btn').forEach(function (btn) {
  btn.addEventListener('click', function () {
    catFilter = btn.getAttribute('data-cat');
    document.querySelectorAll('#catFilters .filter-btn').forEach(function (b) { b.classList.toggle('active', b === btn); });
    render();
  });
});

document.querySelectorAll('.t-btn').forEach(function (btn) {
  btn.addEventListener('click', function () {
    const s = btn.getAttribute('data-stat');
    statFilter = (s === statFilter) ? 'all' : s;
    render();
  });
});

$('stockList').addEventListener('click', function (e) {
  const b = e.target.closest('button[data-act]');
  if (!b) return;
  const id = b.getAttribute('data-id');
  const act = b.getAttribute('data-act');
  if (act === 'minus') openQty(id, -1);
  if (act === 'plus') openQty(id, 1);
  if (act === 'hist') openHistory(id);
  if (act === 'edit') openEdit(id);
  if (act === 'del') deleteItem(id);
});

// ==========================================================
//  ADD NEW STOCK (duplicate se bachao: same item ho to usi me jodo)
// ==========================================================
function findSame(product, brand, model) {
  return items.find(function (it) {
    return norm(it.product_name) === norm(product) && norm(it.brand) === norm(brand) && norm(it.model) === norm(model);
  });
}

['fProduct', 'fBrand', 'fModel'].forEach(function (id) {
  $(id).addEventListener('input', function () {
    const same = findSame($('fProduct').value, $('fBrand').value, $('fModel').value);
    $('matchHint').textContent = same && $('fProduct').value.trim()
      ? 'Ye item pehle se hai (' + same.quantity + ' pcs). Save karne par quantity usi me jud jayegi.'
      : '';
  });
});

$('addForm').addEventListener('submit', async function (e) {
  e.preventDefault();
  const product = clean($('fProduct').value);
  const qty = parseInt($('fQty').value, 10);
  if (!product || isNaN(qty) || qty < 0) { toast('Product name aur quantity daalo.', 'err'); return; }

  $('addBtn').disabled = true;
  const same = findSame(product, $('fBrand').value, $('fModel').value);
  let error;

  if (same && qty > 0) {
    ({ error } = await db.rpc('adjust_stock', {
      p_item_id: same.id, p_change: qty, p_reason: 'Purchase',
      p_note: [clean($('fSupplier').value), $('fBuy').value ? '₹' + $('fBuy').value + '/pc' : null, clean($('fNotes').value)].filter(Boolean).join(' · ') || null
    }));
  } else if (same) {
    $('addBtn').disabled = false;
    toast('Ye item pehle se hai. Quantity 1 ya zyada daalo.', 'err');
    return;
  } else {
    ({ error } = await db.from('stock_items').insert({
      product_name: product,
      category: $('fCategory').value,
      brand: clean($('fBrand').value),
      model: clean($('fModel').value),
      quantity: qty,
      purchase_price: numOrNull($('fBuy').value),
      selling_price: numOrNull($('fSell').value),
      supplier: clean($('fSupplier').value),
      entry_date: $('fDate').value || null,
      notes: clean($('fNotes').value),
      updated_by_name: displayName()
    }));
  }
  $('addBtn').disabled = false;

  if (error) { toast(errorMessage(error), 'err'); return; }
  toast(same ? 'Quantity jod di.' : 'Stock add ho gaya.', 'ok');
  ['fProduct', 'fBrand', 'fModel', 'fQty', 'fBuy', 'fSell', 'fNotes'].forEach(function (id) { $(id).value = ''; });
  $('matchHint').textContent = '';
  loadStock();
});

// ==========================================================
//  QTY +/- (history me record hota hai)
// ==========================================================
function openQty(id, sign) {
  if (!isAdmin) return;
  const it = items.find(function (x) { return x.id === id; });
  if (!it) return;
  qtyMode = { id: id, sign: sign };
  $('qtyTitle').textContent = sign < 0 ? 'Stock se nikalo' : 'Stock me jodo';
  $('qtyItem').textContent = itemLabel(it) + ' — abhi ' + it.quantity + ' pcs';
  $('qNum').value = 1;
  $('qNum').max = sign < 0 ? it.quantity : '';
  $('qReason').innerHTML = (sign < 0 ? REASONS_MINUS : REASONS_PLUS).map(function (r) {
    return '<option>' + r + '</option>';
  }).join('');
  $('qNote').value = '';
  $('qtyModal').classList.remove('hidden');
  $('qNum').focus();
}

$('qCancel').addEventListener('click', function () { $('qtyModal').classList.add('hidden'); });

$('qtyForm').addEventListener('submit', async function (e) {
  e.preventDefault();
  const n = parseInt($('qNum').value, 10);
  if (!qtyMode || isNaN(n) || n < 1) { toast('Sahi number daalo.', 'err'); return; }
  $('qSave').disabled = true;
  const { error } = await db.rpc('adjust_stock', {
    p_item_id: qtyMode.id, p_change: qtyMode.sign * n, p_reason: $('qReason').value, p_note: clean($('qNote').value)
  });
  $('qSave').disabled = false;
  if (error) { toast(errorMessage(error), 'err'); return; }
  $('qtyModal').classList.add('hidden');
  toast('Stock update ho gaya.', 'ok');
  loadStock();
});

// ==========================================================
//  HISTORY
// ==========================================================
async function openHistory(id) {
  if (!isAdmin) return;
  const it = items.find(function (x) { return x.id === id; });
  if (!it) return;
  $('histItem').textContent = itemLabel(it) + ' — abhi ' + it.quantity + ' pcs';
  $('histList').innerHTML = '<div class="empty">Load ho raha hai...</div>';
  $('histModal').classList.remove('hidden');

  const { data, error } = await db.from('stock_movements')
    .select('change, qty_after, reason, note, changed_by_name, changed_at')
    .eq('item_id', id).order('changed_at', { ascending: false }).limit(100);
  if (error) { $('histList').innerHTML = '<div class="empty">' + esc(errorMessage(error)) + '</div>'; return; }
  if (!data.length) { $('histList').innerHTML = '<div class="empty">Koi history nahi.</div>'; return; }

  $('histList').innerHTML = data.map(function (h) {
    const sign = h.change > 0 ? '+' + h.change : String(h.change);
    return '<div class="hist-row"><div>' +
      '<div>' + esc(h.reason === 'Opening' ? 'Shuruaati stock' : h.reason) + (h.note ? ' · ' + esc(h.note) : '') + '</div>' +
      '<div class="muted">' + fmtDateTime(h.changed_at) + (h.changed_by_name ? ' · ' + esc(h.changed_by_name) : '') + '</div>' +
      '</div><div style="text-align:right"><b class="' + (h.change >= 0 ? 'plus' : 'minus') + '">' + sign + '</b>' +
      '<div class="muted">baaki ' + h.qty_after + '</div></div></div>';
  }).join('');
}

$('histClose').addEventListener('click', function () { $('histModal').classList.add('hidden'); });

// ==========================================================
//  EDIT / DELETE (Admin only — database bhi check karta hai)
// ==========================================================
function openEdit(id) {
  if (!isAdmin) return;
  const it = items.find(function (x) { return x.id === id; });
  if (!it) return;
  $('eId').value = it.id;
  $('eProduct').value = it.product_name || '';
  $('eCategory').value = it.category || 'Spare Part';
  $('eBrand').value = it.brand || '';
  $('eModel').value = it.model || '';
  $('eQty').value = it.quantity;
  $('eMin').value = it.min_quantity || 0;
  $('eBuy').value = it.purchase_price == null ? '' : it.purchase_price;
  $('eSell').value = it.selling_price == null ? '' : it.selling_price;
  $('eSupplier').value = it.supplier || '';
  $('eDate').value = it.entry_date || '';
  $('eNotes').value = it.notes || '';
  $('editModal').classList.remove('hidden');
}

$('editCancel').addEventListener('click', function () { $('editModal').classList.add('hidden'); });

$('editForm').addEventListener('submit', async function (e) {
  e.preventDefault();
  const product = clean($('eProduct').value);
  const qty = parseInt($('eQty').value, 10);
  if (!product || isNaN(qty) || qty < 0) { toast('Product name aur quantity daalo.', 'err'); return; }

  const { data, error } = await db.from('stock_items').update({
    product_name: product,
    category: $('eCategory').value,
    brand: clean($('eBrand').value),
    model: clean($('eModel').value),
    quantity: qty,
    min_quantity: parseInt($('eMin').value, 10) || 0,
    purchase_price: numOrNull($('eBuy').value),
    selling_price: numOrNull($('eSell').value),
    supplier: clean($('eSupplier').value),
    entry_date: $('eDate').value || null,
    notes: clean($('eNotes').value),
    updated_by_name: displayName()
  }).eq('id', $('eId').value).select('id');

  if (error) { toast(errorMessage(error), 'err'); return; }
  if (!data || !data.length) { toast('Aapko ye karne ki permission nahi hai.', 'err'); return; }
  $('editModal').classList.add('hidden');
  toast('Changes save ho gaye.', 'ok');
  loadStock();
});

async function deleteItem(id) {
  if (!isAdmin) return;
  const it = items.find(function (x) { return x.id === id; });
  if (!it) return;
  if (!window.confirm('Delete karna hai?\n\n' + itemLabel(it) + ' (' + it.quantity + ' pcs)\n\nIski history bhi hat jayegi.')) return;
  const { data, error } = await db.from('stock_items').delete().eq('id', id).select('id');
  if (error) { toast(errorMessage(error), 'err'); return; }
  if (!data || !data.length) { toast('Aapko ye karne ki permission nahi hai.', 'err'); return; }
  toast('Item delete ho gaya.', 'ok');
  loadStock();
}

// ==========================================================
//  CSV (Admin)
// ==========================================================
$('exportBtn').addEventListener('click', function () {
  const cols = ['product_name', 'category', 'brand', 'model', 'quantity', 'min_quantity', 'purchase_price', 'selling_price', 'supplier', 'entry_date', 'notes', 'updated_by_name', 'updated_at'];
  const lines = [cols.join(',')].concat(filtered().map(function (it) {
    return cols.map(function (c) {
      const v = it[c] == null ? '' : String(it[c]);
      return /[",\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
    }).join(',');
  }));
  const blob = new Blob(['﻿' + lines.join('\n')], { type: 'text/csv;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'stock-' + todayStr() + '.csv';
  a.click();
  URL.revokeObjectURL(a.href);
});

// ==========================================================
//  PAGE KHULTE HI: pehle se login hai to seedha app dikhao
// ==========================================================
(async function init() {
  try {
    const { data } = await db.auth.getSession();
    if (data && data.session) {
      const ok = await loadProfile(data.session.user.id);
      if (ok) { showApp(); return; }
      await db.auth.signOut();
    }
  } catch (err) {
    toast('Internet connection check karo.', 'err');
  }
  $('loginView').classList.remove('hidden');
})();
