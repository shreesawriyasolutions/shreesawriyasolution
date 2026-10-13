// ==========================================================
//  SHREE SAWRIYA SOLUTIONS - CUSTOMER REPAIR TRACKING
//  Customer sirf mobile number daalta hai. Is page par koi
//  secret key nahi hai, sirf public (publishable) key hai.
// ==========================================================

const SUPABASE_URL = 'https://bwldelmfkcynfvbqcneb.supabase.co';
const SUPABASE_KEY = 'sb_publishable_GKmljKQOjWzJ54FdZVPk_g_auEFS9VG';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
});

const STATUSES = ['Received', 'Diagnosing', 'Repair in Progress', 'Waiting for Part', 'Ready for Pickup', 'Delivered'];

const DESC = {
  'Received': 'Aapka phone humein mil gaya',
  'Diagnosing': 'Phone ki jaanch ho rahi hai',
  'Repair in Progress': 'Repair ka kaam chal raha hai',
  'Waiting for Part': 'Part ka intezaar hai',
  'Ready for Pickup': 'Phone ready hai, dukaan se le jayein',
  'Delivered': 'Phone de diya gaya'
};

function $(id) { return document.getElementById(id); }

function esc(s) {
  return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
  });
}

function fmtDate(s) {
  if (!s) return '-';
  const p = String(s).split('-');
  return p.length === 3 ? p[2] + '/' + p[1] + '/' + p[0] : s;
}

function fmtDateTime(s) {
  if (!s) return '';
  return new Date(s).toLocaleString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function statusClass(s) {
  switch (s) {
    case 'Received': return 'st-received';
    case 'Diagnosing': return 'st-diagnosing';
    case 'Repair in Progress': return 'st-progress';
    case 'Waiting for Part': return 'st-waiting';
    case 'Ready for Pickup': return 'st-ready';
    default: return 'st-delivered';
  }
}

function showMsg(type, text) {
  $('result').innerHTML = '<div class="msg ' + type + '">' + esc(text) + '</div>';
}

// ---------- Search ----------
let lastSearch = 0;

$('mobile').addEventListener('input', function () {
  $('mobile').value = $('mobile').value.replace(/\D/g, '');
});

$('trackForm').addEventListener('submit', async function (e) {
  e.preventDefault();
  const m = $('mobile').value.replace(/\D/g, '');

  if (!/^\d{10}$/.test(m)) {
    showMsg('err', 'Kripya 10 digit ka sahi mobile number daalein.');
    return;
  }

  // Bar bar tezi se search rokne ke liye
  const now = Date.now();
  if (now - lastSearch < 2500) {
    showMsg('info', 'Thoda ruk kar dobara try karein.');
    return;
  }
  lastSearch = now;

  $('goBtn').disabled = true;
  showMsg('load', 'Search kar rahe hain...');

  try {
    const { data, error } = await db.rpc('track_repairs', { p_mobile: m });
    if (error) throw error;

    if (!data || data.ok !== true) {
      if (data && data.error === 'busy') {
        showMsg('err', 'Abhi bahut zyada log search kar rahe hain. Thodi der baad try karein.');
      } else {
        showMsg('err', 'Kripya 10 digit ka sahi mobile number daalein.');
      }
    } else {
      render(data);
    }
  } catch (err) {
    showMsg('err', 'Kuch technical problem aa gayi. Internet check karke dobara try karein.');
  }

  $('goBtn').disabled = false;
});

// ---------- Result dikhana ----------
function render(data) {
  const reps = data.repairs || [];

  if (reps.length === 0) {
    showMsg('info', 'Is number par koi repair record nahi mila. Kripya dukaan par sampark karein.');
    return;
  }

  let html = '<div class="hello">Namaste <b>' + esc(data.first_name || '') + '</b>, aapke <b>' +
    reps.length + '</b> repair record mile.</div>';

  reps.forEach(function (r, i) {
    html += card(r, i === 0);
  });

  $('result').innerHTML = html;
}

function card(r, open) {
  const idx = STATUSES.indexOf(r.status);
  const when = {};
  (r.history || []).forEach(function (h) { when[h.status] = h.changed_at; });

  let h = '<div class="rep">';
  h += '<button type="button" class="rep-head" aria-expanded="' + (open ? 'true' : 'false') + '">';
  h += '<div class="rep-top"><div>';
  h += '<div class="rep-code">' + esc(r.repair_code) + '</div>';
  h += '<div class="rep-model">' + esc(r.device_model) + '</div>';
  h += '</div><span class="st ' + statusClass(r.status) + '">' + esc(r.status) + '</span></div>';
  h += '<div class="rep-sub">Received: ' + esc(fmtDate(r.received_date)) + ' &bull; Last updated: ' + esc(fmtDateTime(r.updated_at)) + '</div>';
  h += '<div class="tap">' + (open ? 'Chhupane ke liye tap karein' : 'Poori detail dekhne ke liye tap karein') + '</div>';
  h += '</button>';

  h += '<div class="rep-body' + (open ? '' : ' hidden') + '">';

  if (r.status === 'Ready for Pickup') {
    h += '<div class="ready-banner">Aapka phone ready hai. Kripya dukaan se le jayein.</div>';
  }

  h += '<div style="margin-top:8px;">';
  if (r.problem) h += row('Problem', r.problem);
  h += row('Received Date', fmtDate(r.received_date));
  h += row('Last Updated', fmtDateTime(r.updated_at));
  if (r.estimated_delivery) h += row('Estimated Delivery', fmtDate(r.estimated_delivery));
  if (r.public_note) h += row('Note', r.public_note);
  h += '</div>';

  h += '<div class="sec-title">REPAIR PROGRESS</div>';
  h += '<div class="tl">';
  STATUSES.forEach(function (s, i) {
    let cls = 'pending';
    if (i < idx) cls = 'done';
    else if (i === idx) cls = 'current';
    const isFinal = (s === 'Ready for Pickup' || s === 'Delivered') ? ' final' : '';
    h += '<div class="step ' + cls + isFinal + '">';
    h += '<div class="dot">' + (cls === 'done' ? '&#10003;' : '') + '</div>';
    h += '<div><div class="s-name">' + esc(s) + '</div>';
    h += '<div class="s-desc">' + esc(DESC[s]) + '</div>';
    if (when[s] && cls !== 'pending') h += '<div class="s-time">' + esc(fmtDateTime(when[s])) + '</div>';
    h += '</div></div>';
  });
  h += '</div>';

  h += '</div></div>';
  return h;
}

function row(label, value) {
  return '<div class="info-row"><span class="l">' + esc(label) + '</span><span class="v">' + esc(value) + '</span></div>';
}

// Card kholna / band karna
$('result').addEventListener('click', function (e) {
  const head = e.target.closest('.rep-head');
  if (!head) return;
  const body = head.parentNode.querySelector('.rep-body');
  const isOpen = !body.classList.contains('hidden');
  body.classList.toggle('hidden', isOpen);
  head.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
  head.querySelector('.tap').textContent = isOpen ? 'Poori detail dekhne ke liye tap karein' : 'Chhupane ke liye tap karein';
});

// Home page se number lekar aaye to apne aap search karo (?m=9876543210)
(function autoSearch() {
  const m = new URLSearchParams(window.location.search).get('m');
  if (!m || !/^\d{10}$/.test(m)) return;
  $('mobile').value = m;
  // Number ko address bar se hata do (history me na rahe)
  try { window.history.replaceState({}, '', window.location.pathname); } catch (e) {}
  $('trackForm').dispatchEvent(new Event('submit', { cancelable: true }));
})();
