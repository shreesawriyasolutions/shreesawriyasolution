import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../errors/app_exception.dart';
import '../models/models.dart';
import 'shop_repository.dart';

class SupabaseShopRepository implements ShopRepository {
  SupabaseShopRepository(this.db);

  final SupabaseClient db;

  @override
  String? get currentUserId => db.auth.currentUser?.id;

  Future<Profile?> _profile(String uid) async {
    final m = await db.from('profiles').select('id, role, can_view, full_name, created_at').eq('id', uid).maybeSingle();
    return m == null ? null : Profile.fromMap(m);
  }

  @override
  Future<Profile?> restoreSession() async {
    final uid = db.auth.currentSession?.user.id;
    if (uid == null) return null;
    final p = await _profile(uid);
    if (p == null) await db.auth.signOut();
    return p;
  }

  @override
  Future<Profile> signIn(String email, String password) async {
    final AuthResponse res;
    try {
      res = await db.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      throw AppException(m.contains('fetch') || m.contains('socket') ? 'Internet check karein.' : 'Email ya password galat hai.');
    }
    final p = res.user == null ? null : await _profile(res.user!.id);
    if (p == null) {
      await db.auth.signOut();
      throw const AppException('Is account ko app ki permission nahi hai. Admin se baat karein.');
    }
    return p;
  }

  @override
  Future<void> signOut() => db.auth.signOut();

  // ---------- loads ----------
  @override
  Future<List<Repair>> loadRepairs() async {
    final rows = await db.from('repairs').select('*, customers(name, mobile)').order('created_at', ascending: false).limit(1000);
    return rows.map(Repair.fromMap).toList();
  }

  @override
  Future<List<Sale>> loadSales({String? from, String? to}) async {
    var q = db.from('sales_entries').select();
    if (from != null) q = q.gte('entry_date', from);
    if (to != null) q = q.lte('entry_date', to);
    final rows = await q.order('entry_date', ascending: false).order('created_at', ascending: false).limit(3000);
    return rows.map(Sale.fromMap).toList();
  }

  @override
  Future<List<Bill>> loadBills() async {
    final rows = await db.from('bills').select().order('bill_date', ascending: false).order('created_at', ascending: false).limit(2000);
    return rows.map(Bill.fromMap).toList();
  }

  @override
  Future<List<StockItem>> loadStock() async {
    final rows = await db.from('stock_items').select().order('product_name').limit(3000);
    return rows.map(StockItem.fromMap).toList();
  }

  @override
  Future<List<Profile>> loadStaff() async {
    final rows = await db.from('profiles').select().order('created_at');
    return rows.map(Profile.fromMap).toList();
  }

  // ---------- repairs ----------
  @override
  Future<String?> lookupCustomer(String mobile) async {
    final m = await db.from('customers').select('name').eq('mobile', mobile).maybeSingle();
    return m?['name']?.toString();
  }

  @override
  Future<(String, String)> createRepair({required String mobile, required String name, required Map<String, dynamic> data}) async {
    final cust = await db.rpc('add_customer_or_get', params: {'p_mobile': mobile, 'p_name': name});
    final custId = (cust as List).first['out_customer_id'];
    final rows = await db.from('repairs').insert({...data, 'customer_id': custId}).select('id, repair_code');
    final r = rows.first;
    return (r['id'].toString(), r['repair_code'].toString());
  }

  @override
  Future<void> updateRepair(String id, Map<String, dynamic> data) async {
    final d = await db.from('repairs').update(data).eq('id', id).select('id');
    if (d.isEmpty) throw const AppException('Sirf Admin edit kar sakta hai.');
  }

  @override
  Future<void> setRepairStatus(String id, String status) async {
    final d = await db.from('repairs').update({'status': status}).eq('id', id).select('id');
    if (d.isEmpty) throw const AppException('Status update nahi hua.');
  }

  @override
  Future<List<StatusHistory>> repairHistory(String id) async {
    final rows = await db
        .from('repair_status_history')
        .select('status, changed_at, changed_by')
        .eq('repair_id', id)
        .order('changed_at', ascending: false);
    return rows.map(StatusHistory.fromMap).toList();
  }

  // ---------- sales ----------
  @override
  Future<void> createSale(Map<String, dynamic> entry, List<(String, int)> parts) async {
    await db.rpc('create_sale_with_parts', params: {
      'p_entry': entry,
      'p_parts': [for (final p in parts) {'item_id': p.$1, 'qty': p.$2}],
    });
  }

  @override
  Future<void> updateSale(String id, Map<String, dynamic> data) async {
    final d = await db.from('sales_entries').update(data).eq('id', id).select('id');
    if (d.isEmpty) throw const AppException('Sirf Admin edit kar sakta hai.');
  }

  @override
  Future<List<String>> saleParts(String id) async {
    final rows = await db.from('sale_entry_parts').select('item_label, qty').eq('sale_entry_id', id);
    return rows.map((r) => '${r['item_label']} × ${r['qty']}').toList();
  }

  // ---------- bills ----------
  @override
  Future<String> uploadBillFile(PickedUpload file, String kind) async {
    const allowed = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
    if (!allowed.contains(file.contentType)) throw const AppException('Sirf JPG, PNG, WEBP ya PDF file allowed hai.');
    if (file.bytes.length > 10 * 1024 * 1024) throw const AppException('File 10 MB se badi hai.');
    final ext = switch (file.contentType) {
      'application/pdf' => 'pdf',
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final rnd = Random.secure();
    final rid = '${DateTime.now().millisecondsSinceEpoch}-${List.generate(8, (_) => rnd.nextInt(16).toRadixString(16)).join()}';
    final path = '$currentUserId/$kind-$rid.$ext';
    await db.storage.from(AppConfig.billsBucket).uploadBinary(
          path,
          Uint8List.fromList(file.bytes),
          fileOptions: FileOptions(contentType: file.contentType, upsert: false),
        );
    return path;
  }

  @override
  Future<void> insertBill(Map<String, dynamic> data) async {
    await db.from('bills').insert(data);
  }

  @override
  Future<String> signedFileUrl(String path) => db.storage.from(AppConfig.billsBucket).createSignedUrl(path, 60);

  // ---------- stock ----------
  @override
  Future<void> addStockItem(Map<String, dynamic> data) async {
    await db.from('stock_items').insert(data);
  }

  @override
  Future<void> adjustStock(String id, int change, String reason, String? note) async {
    await db.rpc('adjust_stock', params: {
      'p_item_id': id,
      'p_change': change,
      'p_reason': reason,
      'p_repair_id': null,
      'p_note': note,
    });
  }

  @override
  Future<void> updateStock(String id, Map<String, dynamic> data) async {
    final d = await db.from('stock_items').update(data).eq('id', id).select('id');
    if (d.isEmpty) throw const AppException('Sirf Admin edit kar sakta hai.');
  }

  @override
  Future<List<StockMovement>> stockHistory(String id) async {
    final rows = await db
        .from('stock_movements')
        .select('change, qty_after, reason, note, changed_by_name, changed_at')
        .eq('item_id', id)
        .order('changed_at', ascending: false)
        .limit(50);
    return rows.map(StockMovement.fromMap).toList();
  }

  // ---------- staff ----------
  @override
  Future<bool> createStaff({required String name, required String email, required String password}) async {
    // Public signup band hai (security), isliye account server function "create-staff"
    // banata hai. Woh check karta hai ki bulane wala Admin hai.
    try {
      await db.functions.invoke('create-staff', body: {'name': name, 'email': email, 'password': password});
      return true;
    } on FunctionException catch (e) {
      final d = e.details;
      final msg = d is Map ? d['error']?.toString() : null;
      throw AppException(msg ?? 'Account nahi bana. Dobara try karein.');
    }
  }

  @override
  Future<void> updateProfile(String id, Map<String, dynamic> data) async {
    final d = await db.from('profiles').update(data).eq('id', id).select('id');
    if (d.isEmpty) throw const AppException('Update nahi hua. Sirf Admin badal sakta hai.');
  }

  // ---------- delete ----------
  @override
  Future<void> delete(DeleteKind kind, String id, {List<String> filePaths = const []}) async {
    final table = switch (kind) {
      DeleteKind.repair => 'repairs',
      DeleteKind.sale => 'sales_entries',
      DeleteKind.bill => 'bills',
      DeleteKind.stock => 'stock_items',
      DeleteKind.staff => 'profiles',
    };
    final d = await db.from(table).delete().eq('id', id).select('id');
    if (d.isEmpty) throw const AppException('Delete nahi hua. Sirf Admin delete kar sakta hai.');
    if (kind == DeleteKind.bill && filePaths.isNotEmpty) {
      await db.storage.from(AppConfig.billsBucket).remove(filePaths);
    }
  }
}
