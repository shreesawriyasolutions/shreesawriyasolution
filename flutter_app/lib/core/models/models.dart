import '../config.dart';
import '../utils/format.dart';

List<String> _strList(Object? v) => v is List ? v.map((e) => e.toString()).toList() : const [];
String? _s(Object? v) => v?.toString();
int _i(Object? v) => toNum(v).round();
double? _dn(Object? v) => v == null ? null : toNum(v);

class Profile {
  const Profile({required this.id, required this.role, required this.canView, this.fullName, this.createdAt});

  final String id;
  final String role;
  final bool canView;
  final String? fullName;
  final String? createdAt;

  bool get isAdmin => role == 'admin';
  String get name => shortName(fullName).isEmpty ? 'Staff' : shortName(fullName);

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: _s(m['id']) ?? '',
        role: _s(m['role']) ?? 'staff',
        canView: m['can_view'] == true,
        fullName: _s(m['full_name']),
        createdAt: _s(m['created_at']),
      );
}

class Repair {
  const Repair({
    required this.id,
    required this.code,
    required this.status,
    required this.deviceModel,
    this.customerName,
    this.customerMobile,
    this.problem,
    this.imei,
    this.estimatedCharge,
    this.finalCharge,
    this.advancePaid = 0,
    this.receivedDate,
    this.estimatedDelivery,
    this.deliveredOn,
    this.warrantyDays,
    this.lockCode,
    this.accessories = const [],
    this.conditionChecks = const [],
    this.publicNote,
    this.internalNote,
    this.updatedAt,
  });

  final String id;
  final String code;
  final String status;
  final String deviceModel;
  final String? customerName;
  final String? customerMobile;
  final String? problem;
  final String? imei;
  final double? estimatedCharge;
  final double? finalCharge;
  final double advancePaid;
  final String? receivedDate;
  final String? estimatedDelivery;
  final String? deliveredOn;
  final int? warrantyDays;
  final String? lockCode;
  final List<String> accessories;
  final List<String> conditionChecks;
  final String? publicNote;
  final String? internalNote;
  final String? updatedAt;

  bool get isOpen => !closedStatuses.contains(status);
  double get due => toNum(finalCharge ?? estimatedCharge) - advancePaid;

  String get searchText =>
      [code, deviceModel, problem, imei, customerName, customerMobile].whereType<String>().join(' ').toLowerCase();

  factory Repair.fromMap(Map<String, dynamic> m) {
    final c = (m['customers'] is Map) ? Map<String, dynamic>.from(m['customers'] as Map) : const <String, dynamic>{};
    return Repair(
      id: _s(m['id']) ?? '',
      code: _s(m['repair_code']) ?? '',
      status: _s(m['status']) ?? 'Received',
      deviceModel: _s(m['device_model']) ?? '',
      customerName: _s(c['name']),
      customerMobile: _s(c['mobile']),
      problem: _s(m['problem']),
      imei: _s(m['imei']),
      estimatedCharge: _dn(m['estimated_charge']),
      finalCharge: _dn(m['final_charge']),
      advancePaid: toNum(m['advance_paid']),
      receivedDate: _s(m['received_date']),
      estimatedDelivery: _s(m['estimated_delivery']),
      deliveredOn: _s(m['delivered_on']),
      warrantyDays: m['warranty_days'] == null ? null : _i(m['warranty_days']),
      lockCode: _s(m['lock_code']),
      accessories: _strList(m['accessories']),
      conditionChecks: _strList(m['condition_checks']),
      publicNote: _s(m['public_note']),
      internalNote: _s(m['internal_note']),
      updatedAt: _s(m['updated_at']),
    );
  }
}

class StatusHistory {
  const StatusHistory({required this.status, this.changedAt, this.changedBy});
  final String status;
  final String? changedAt;
  final String? changedBy;

  factory StatusHistory.fromMap(Map<String, dynamic> m) =>
      StatusHistory(status: _s(m['status']) ?? '', changedAt: _s(m['changed_at']), changedBy: _s(m['changed_by']));
}

class Sale {
  const Sale({
    required this.id,
    required this.entryDate,
    required this.description,
    required this.amount,
    required this.expense,
    required this.paymentMode,
    required this.staffName,
    this.profit,
    this.customerName,
    this.notes,
  });

  final String id;
  final String entryDate;
  final String description;
  final double amount;
  final double expense;
  final double? profit;
  final String paymentMode;
  final String staffName;
  final String? customerName;
  final String? notes;

  String get searchText => [description, customerName, staffName, notes].whereType<String>().join(' ').toLowerCase();

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: _s(m['id']) ?? '',
        entryDate: (_s(m['entry_date']) ?? '').padRight(10).substring(0, 10).trim(),
        description: _s(m['sale_description']) ?? '',
        amount: toNum(m['amount_received']),
        expense: toNum(m['expense']),
        profit: _dn(m['profit']),
        paymentMode: _s(m['payment_mode']) ?? 'Cash',
        staffName: _s(m['staff_name']) ?? '',
        customerName: _s(m['customer_name']),
        notes: _s(m['notes']),
      );
}

class Bill {
  const Bill({
    required this.id,
    required this.billDate,
    required this.billType,
    required this.partyName,
    required this.uploadedBy,
    this.mobile,
    this.phoneModel,
    this.imei,
    this.workType,
    this.amount,
    this.notes,
    this.billFilePath,
    this.idFilePath,
    this.extraFilePaths = const [],
    this.createdAt,
  });

  final String id;
  final String? billDate;
  final String billType;
  final String partyName;
  final String uploadedBy;
  final String? mobile;
  final String? phoneModel;
  final String? imei;
  final String? workType;
  final double? amount;
  final String? notes;
  final String? billFilePath;
  final String? idFilePath;
  final List<String> extraFilePaths;
  final String? createdAt;

  String get searchText =>
      [partyName, mobile, imei, phoneModel, workType, notes, uploadedBy].whereType<String>().join(' ').toLowerCase();

  /// [(path, label)] jaise website: Bill 1, Bill 2, ID 1.
  List<(String, String)> get files {
    var bn = 0, idn = 0;
    return [billFilePath, idFilePath, ...extraFilePaths].whereType<String>().where((p) => p.isNotEmpty).map((p) {
      final isId = p.split('/').last.startsWith('id-');
      return (p, isId ? 'ID ${++idn}' : 'Bill ${++bn}');
    }).toList();
  }

  factory Bill.fromMap(Map<String, dynamic> m) => Bill(
        id: _s(m['id']) ?? '',
        billDate: _s(m['bill_date']),
        billType: _s(m['bill_type']) ?? 'Purchase Bill',
        partyName: _s(m['party_name']) ?? '',
        uploadedBy: _s(m['uploaded_by_name']) ?? '',
        mobile: _s(m['mobile_number']),
        phoneModel: _s(m['phone_model']),
        imei: _s(m['imei']),
        workType: _s(m['work_type']),
        amount: _dn(m['amount']),
        notes: _s(m['notes']),
        billFilePath: _s(m['bill_file_path']),
        idFilePath: _s(m['id_file_path']),
        extraFilePaths: _strList(m['extra_file_paths']),
        createdAt: _s(m['created_at']),
      );
}

enum StockState { ok, low, out }

class StockItem {
  const StockItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    this.brand,
    this.model,
    this.minQuantity = 0,
    this.purchasePrice,
    this.sellingPrice,
    this.supplier,
    this.notes,
  });

  final String id;
  final String productName;
  final String category;
  final int quantity;
  final String? brand;
  final String? model;
  final int minQuantity;
  final double? purchasePrice;
  final double? sellingPrice;
  final String? supplier;
  final String? notes;

  String get label => [productName, brand, model].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
  String get subtitle {
    final s = [brand, model].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return s.isEmpty ? category : s;
  }

  StockState get state => quantity <= 0
      ? StockState.out
      : (minQuantity > 0 && quantity <= minQuantity)
          ? StockState.low
          : StockState.ok;

  String get searchText => [productName, brand, model, supplier, notes].whereType<String>().join(' ').toLowerCase();

  factory StockItem.fromMap(Map<String, dynamic> m) => StockItem(
        id: _s(m['id']) ?? '',
        productName: _s(m['product_name']) ?? '',
        category: _s(m['category']) ?? 'Other',
        quantity: _i(m['quantity']),
        brand: _s(m['brand']),
        model: _s(m['model']),
        minQuantity: _i(m['min_quantity']),
        purchasePrice: _dn(m['purchase_price']),
        sellingPrice: _dn(m['selling_price']),
        supplier: _s(m['supplier']),
        notes: _s(m['notes']),
      );
}

class StockMovement {
  const StockMovement({required this.change, required this.qtyAfter, this.reason, this.note, this.by, this.at});
  final int change;
  final int qtyAfter;
  final String? reason;
  final String? note;
  final String? by;
  final String? at;

  factory StockMovement.fromMap(Map<String, dynamic> m) => StockMovement(
        change: _i(m['change']),
        qtyAfter: _i(m['qty_after']),
        reason: _s(m['reason']),
        note: _s(m['note']),
        by: _s(m['changed_by_name']),
        at: _s(m['changed_at']),
      );
}

/// File chuni hui (bill upload ke liye).
class PickedUpload {
  const PickedUpload({required this.bytes, required this.contentType, required this.name});
  final List<int> bytes;
  final String contentType;
  final String name;
}
