import '../errors/app_exception.dart';
import '../models/models.dart';
import '../utils/format.dart';
import 'shop_repository.dart';

/// Bina internet/login ke design dekhne aur tests ke liye nakli data.
/// Chalane ke liye: flutter run --dart-define=DEMO=true
class DemoShopRepository implements ShopRepository {
  DemoShopRepository({this.admin = true});

  final bool admin;
  int _seq = 200;

  String _day(int ago) => dstr(DateTime.now().subtract(Duration(days: ago)));

  late final Profile _me = Profile(id: 'u1', role: admin ? 'admin' : 'staff', canView: true, fullName: 'Ankush', createdAt: _day(300));

  late final List<Map<String, dynamic>> _repairs = [
    _r('SSS-0187', 'Ready for Pickup', 'Rohit Sharma', '9812345670', 'iPhone 13 Pro Max', 'Display green line', 6500, 1000, 1),
    _r('SSS-0186', 'Repair in Progress', 'Pooja Rani', '9876501234', 'Samsung Galaxy Z Flip5', 'Touch kaam nahi karta', 4200, 500, 1),
    _r('SSS-0185', 'Waiting for Part', 'Sandeep Kumar', '9466012345', 'Vivo Y20', 'Charging port', 650, 0, 2),
    _r('SSS-0184', 'Received', 'Neha Verma', '9996123456', 'Redmi Note 12', 'Battery jaldi khatam', 1400, 200, 0),
    _r('SSS-0183', 'Diagnosing', 'Amit Saini', '9034567812', 'OnePlus Nord CE 3', 'Dead, pani laga', null, 0, 0),
    _r('SSS-0182', 'Ready for Pickup', 'Kavita Devi', '9812098765', 'Oppo A78', 'Back glass', 900, 300, 3),
    _r('SSS-0181', 'Delivered', 'Vikas Rana', '9729012345', 'iPhone 11', 'Face ID', 3500, 1000, 5),
  ];

  Map<String, dynamic> _r(String code, String status, String name, String mobile, String model, String problem, num? est,
          num adv, int ago) =>
      {
        'id': code,
        'repair_code': code,
        'status': status,
        'customers': {'name': name, 'mobile': mobile},
        'device_model': model,
        'problem': problem,
        'estimated_charge': est,
        'advance_paid': adv,
        'received_date': _day(ago),
        'estimated_delivery': _day(ago - 2),
        'accessories': ['SIM', 'Back Cover'],
        'condition_checks': ['Phone ON hota hai', 'Camera theek'],
        'public_note': status == 'Ready for Pickup' ? 'Phone ready hai, shaam 8 baje tak le jayein.' : null,
        'updated_at': DateTime.now().subtract(Duration(hours: ago * 5 + 1)).toIso8601String(),
      };

  late final List<Map<String, dynamic>> _sales = [
    for (var i = 0; i < 7; i++) ...[
      _s('s$i-a', _day(i), 'iPhone display change', 4200.0 + i * 350, 2600, 'UPI', 'Ankush', 'Rohit'),
      _s('s$i-b', _day(i), 'Charging port + cleaning', 650, 180, 'Cash', 'Deepak', null),
      if (i.isEven) _s('s$i-c', _day(i), 'Tempered glass + cover', 450, 120, 'Cash', 'Deepak', null),
    ],
  ];

  Map<String, dynamic> _s(String id, String d, String desc, num amt, num exp, String pay, String staff, String? cust) => {
        'id': id,
        'entry_date': d,
        'sale_description': desc,
        'amount_received': amt,
        'expense': exp,
        'profit': amt - exp,
        'payment_mode': pay,
        'staff_name': staff,
        'customer_name': cust,
      };

  late final List<Map<String, dynamic>> _bills = [
    {'id': 'b1', 'bill_date': _day(0), 'bill_type': 'Purchase Bill', 'party_name': 'Mobile Spares Karnal', 'amount': 18500, 'uploaded_by_name': 'Ankush', 'bill_file_path': 'u1/bill-1.jpg', 'created_at': DateTime.now().toIso8601String()},
    {'id': 'b2', 'bill_date': _day(1), 'bill_type': 'Unlocking Job', 'party_name': 'Rajesh', 'mobile_number': '9812000011', 'phone_model': 'Vivo Y21', 'imei': '356789012345678', 'work_type': 'FRP Unlock', 'amount': 500, 'uploaded_by_name': 'Deepak', 'bill_file_path': 'u1/bill-2.jpg', 'id_file_path': 'u1/id-2.jpg', 'created_at': DateTime.now().toIso8601String()},
    {'id': 'b3', 'bill_date': _day(2), 'bill_type': 'Sale Bill', 'party_name': 'Sunita', 'phone_model': 'Samsung A15', 'amount': 11200, 'uploaded_by_name': 'Ankush', 'bill_file_path': 'u1/bill-3.pdf', 'created_at': DateTime.now().toIso8601String()},
  ];

  late final List<Map<String, dynamic>> _stock = [
    _k('k1', 'Display', 'Apple', 'iPhone 13 Pro Max', 'Spare Part', 2, 2, 5200, 6500),
    _k('k2', 'Battery', 'Xiaomi', 'Redmi Note 12', 'Spare Part', 6, 2, 650, 1200),
    _k('k3', 'Charging port', 'Vivo', 'Y20', 'Spare Part', 0, 2, 90, 400),
    _k('k4', 'Fast charger 33W', 'Generic', null, 'Accessory', 14, 5, 220, 499),
    _k('k5', 'Tempered glass', 'Generic', null, 'Accessory', 48, 20, 15, 99),
    _k('k6', 'Back glass', 'Oppo', 'A78', 'Spare Part', 1, 2, 180, 600),
  ];

  Map<String, dynamic> _k(String id, String p, String? b, String? m, String c, int q, int min, num buy, num sell) => {
        'id': id,
        'product_name': p,
        'brand': b,
        'model': m,
        'category': c,
        'quantity': q,
        'min_quantity': min,
        'purchase_price': buy,
        'selling_price': sell,
        'supplier': 'Mobile Spares Karnal',
      };

  late final List<Map<String, dynamic>> _staff = [
    {'id': 'u1', 'role': 'admin', 'can_view': true, 'full_name': 'Ankush', 'created_at': _day(300)},
    {'id': 'u2', 'role': 'staff', 'can_view': false, 'full_name': 'Deepak', 'created_at': _day(120)},
    {'id': 'u3', 'role': 'staff', 'can_view': true, 'full_name': 'Manish', 'created_at': _day(40)},
  ];

  Future<void> _wait() => Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  String? get currentUserId => 'u1';

  @override
  Future<Profile?> restoreSession() async {
    // Web preview me .../#/login kholo to login screen dikhe.
    if (Uri.base.fragment.contains('login')) return null;
    return _me;
  }

  @override
  Future<Profile> signIn(String email, String password) async => _me;

  @override
  Future<void> signOut() async {}

  @override
  Future<List<Repair>> loadRepairs() async {
    await _wait();
    return _repairs.map(Repair.fromMap).toList();
  }

  @override
  Future<List<Sale>> loadSales({String? from, String? to}) async {
    await _wait();
    return _sales
        .where((s) => (from == null || s['entry_date'].compareTo(from) >= 0) && (to == null || s['entry_date'].compareTo(to) <= 0))
        .map(Sale.fromMap)
        .toList();
  }

  @override
  Future<List<Bill>> loadBills() async => _bills.map(Bill.fromMap).toList();

  @override
  Future<List<StockItem>> loadStock() async => _stock.map(StockItem.fromMap).toList();

  @override
  Future<List<Profile>> loadStaff() async => _staff.map(Profile.fromMap).toList();

  @override
  Future<String?> lookupCustomer(String mobile) async {
    for (final r in _repairs) {
      final c = r['customers'] as Map;
      if (c['mobile'] == mobile) return c['name'] as String;
    }
    return null;
  }

  @override
  Future<(String, String)> createRepair({required String mobile, required String name, required Map<String, dynamic> data}) async {
    final code = 'SSS-0${_seq++}';
    _repairs.insert(0, {...data, 'id': code, 'repair_code': code, 'customers': {'name': name, 'mobile': mobile}, 'updated_at': DateTime.now().toIso8601String()});
    return (code, code);
  }

  Map<String, dynamic> _find(List<Map<String, dynamic>> l, String id) =>
      l.firstWhere((x) => x['id'] == id, orElse: () => throw const AppException('Item nahi mila'));

  @override
  Future<void> updateRepair(String id, Map<String, dynamic> data) async => _find(_repairs, id).addAll(data);

  @override
  Future<void> setRepairStatus(String id, String status) async =>
      _find(_repairs, id).addAll({'status': status, 'updated_at': DateTime.now().toIso8601String()});

  @override
  Future<List<StatusHistory>> repairHistory(String id) async => [
        StatusHistory(status: _find(_repairs, id)['status'] as String, changedAt: DateTime.now().toIso8601String(), changedBy: 'u1'),
        StatusHistory(status: 'Received', changedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), changedBy: 'u2'),
      ];

  @override
  Future<void> createSale(Map<String, dynamic> entry, List<(String, int)> parts) async {
    final amt = toNum(entry['amount_received']), exp = toNum(entry['expense']);
    _sales.insert(0, {...entry, 'id': 's${_seq++}', 'profit': amt - exp});
    for (final p in parts) {
      final k = _find(_stock, p.$1);
      k['quantity'] = (k['quantity'] as int) - p.$2;
    }
  }

  @override
  Future<void> updateSale(String id, Map<String, dynamic> data) async => _find(_sales, id).addAll(data);

  @override
  Future<List<String>> saleParts(String id) async => const [];

  @override
  Future<String> uploadBillFile(PickedUpload file, String kind) async => 'u1/$kind-${_seq++}.jpg';

  @override
  Future<void> insertBill(Map<String, dynamic> data) async =>
      _bills.insert(0, {...data, 'id': 'b${_seq++}', 'created_at': DateTime.now().toIso8601String()});

  @override
  Future<String> signedFileUrl(String path) async => 'https://shreesawriyasolutions.in/logo.png';

  @override
  Future<void> addStockItem(Map<String, dynamic> data) async => _stock.add({...data, 'id': 'k${_seq++}', 'min_quantity': 0});

  @override
  Future<void> adjustStock(String id, int change, String reason, String? note) async {
    final k = _find(_stock, id);
    final next = (k['quantity'] as int) + change;
    if (next < 0) throw const AppException('Itna stock nahi hai.');
    k['quantity'] = next;
  }

  @override
  Future<void> updateStock(String id, Map<String, dynamic> data) async => _find(_stock, id).addAll(data);

  @override
  Future<List<StockMovement>> stockHistory(String id) async => [
        StockMovement(change: 5, qtyAfter: toNum(_find(_stock, id)['quantity']).round(), reason: 'Purchase', by: 'Ankush', at: DateTime.now().toIso8601String()),
      ];

  @override
  Future<bool> createStaff({required String name, required String email, required String password}) async {
    _staff.add({'id': 'u${_seq++}', 'role': 'staff', 'can_view': false, 'full_name': name, 'created_at': today()});
    return true;
  }

  @override
  Future<void> updateProfile(String id, Map<String, dynamic> data) async => _find(_staff, id).addAll(data);

  @override
  Future<void> delete(DeleteKind kind, String id, {List<String> filePaths = const []}) async {
    final l = switch (kind) {
      DeleteKind.repair => _repairs,
      DeleteKind.sale => _sales,
      DeleteKind.bill => _bills,
      DeleteKind.stock => _stock,
      DeleteKind.staff => _staff,
    };
    l.removeWhere((x) => x['id'] == id);
  }
}
