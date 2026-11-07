import '../models/models.dart';

enum DeleteKind { repair, sale, bill, stock, staff }

/// Sab data yahin se aata/jata hai. Asli app me [SupabaseShopRepository],
/// design preview / tests me [DemoShopRepository].
abstract class ShopRepository {
  String? get currentUserId;

  Future<Profile?> restoreSession();
  Future<Profile> signIn(String email, String password);
  Future<void> signOut();

  Future<List<Repair>> loadRepairs();
  Future<List<Sale>> loadSales({String? from, String? to});
  Future<List<Bill>> loadBills();
  Future<List<StockItem>> loadStock();
  Future<List<Profile>> loadStaff();

  Future<String?> lookupCustomer(String mobile);
  Future<(String id, String code)> createRepair({required String mobile, required String name, required Map<String, dynamic> data});
  Future<void> updateRepair(String id, Map<String, dynamic> data);
  Future<void> setRepairStatus(String id, String status);
  Future<List<StatusHistory>> repairHistory(String id);

  Future<void> createSale(Map<String, dynamic> entry, List<(String itemId, int qty)> parts);
  Future<void> updateSale(String id, Map<String, dynamic> data);
  Future<List<String>> saleParts(String id);

  Future<String> uploadBillFile(PickedUpload file, String kind);
  Future<void> insertBill(Map<String, dynamic> data);
  Future<String> signedFileUrl(String path);

  Future<void> addStockItem(Map<String, dynamic> data);
  Future<void> adjustStock(String id, int change, String reason, String? note);
  Future<void> updateStock(String id, Map<String, dynamic> data);
  Future<List<StockMovement>> stockHistory(String id);

  /// true = account turant active; false = email confirm karna hoga.
  Future<bool> createStaff({required String name, required String email, required String password});
  Future<void> updateProfile(String id, Map<String, dynamic> data);

  Future<void> delete(DeleteKind kind, String id, {List<String> filePaths = const []});
}
