import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/shop_repository.dart';
import '../models/models.dart';
import '../utils/format.dart';

/// main() me override hota hai (Supabase ya Demo).
final repositoryProvider = Provider<ShopRepository>((ref) => throw UnimplementedError('repositoryProvider override nahi hua'));

/// Simple value holder (filters, tab selections).
class ValueHolder<T> extends Notifier<T> {
  ValueHolder(this.initial);
  final T initial;

  @override
  T build() => initial;

  void set(T value) => state = value;
}

// ---------------- session ----------------
class SessionController extends AsyncNotifier<Profile?> {
  ShopRepository get _repo => ref.read(repositoryProvider);

  @override
  Future<Profile?> build() => _repo.restoreSession();

  Future<void> signIn(String email, String password) async {
    final p = await _repo.signIn(email, password);
    state = AsyncData(p);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(null);
  }

  void updateName(String? name) {
    final p = state.value;
    if (p == null) return;
    state = AsyncData(Profile(id: p.id, role: p.role, canView: p.canView, fullName: name, createdAt: p.createdAt));
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, Profile?>(SessionController.new);

/// Logged-in profile (null = logged out / loading).
final profileProvider = Provider<Profile?>((ref) => ref.watch(sessionProvider).value);
final isAdminProvider = Provider<bool>((ref) => ref.watch(profileProvider)?.isAdmin ?? false);
final canViewSalesProvider = Provider<bool>((ref) {
  final p = ref.watch(profileProvider);
  return p != null && (p.isAdmin || p.canView);
});

/// Har list wala controller isse extend karta hai: refresh() purana data
/// dikhate hue chupchaap naya laata hai.
abstract class ListController<T> extends AsyncNotifier<List<T>> {
  ShopRepository get repo => ref.read(repositoryProvider);

  Future<List<T>> load();

  @override
  Future<List<T>> build() {
    // Login badalte hi dobara load.
    ref.watch(profileProvider.select((p) => '${p?.id}-${p?.role}-${p?.canView}'));
    if (ref.read(profileProvider) == null) return Future.value(<T>[]);
    return load();
  }

  Future<void> refresh() async {
    if (ref.read(profileProvider) == null) return;
    final next = await AsyncValue.guard(load);
    if (!ref.mounted) return;
    // Internet chala gaya to purana data dikhate raho; data hi nahi tha to error dikhao.
    if (next.hasError && state.hasValue) return;
    state = next;
  }
}

// ---------------- repairs ----------------
class RepairsController extends ListController<Repair> {
  @override
  Future<List<Repair>> load() => repo.loadRepairs();
}

final repairsProvider = AsyncNotifierProvider<RepairsController, List<Repair>>(RepairsController.new);

/// 'open' | 'all' | status key
final repairFilterProvider = NotifierProvider<ValueHolder<String>, String>(() => ValueHolder('open'));

// ---------------- sales ----------------
enum SalesPeriod { today, week, month, all, range }

class SalesFilter {
  const SalesFilter({this.period = SalesPeriod.today, this.from, this.to});
  final SalesPeriod period;
  final String? from;
  final String? to;

  /// [from, to] (null = koi limit nahi), website wale periodRange() jaisa.
  (String?, String?) get range {
    final now = DateTime.now();
    final t = dstr(now);
    return switch (period) {
      SalesPeriod.today => (t, t),
      SalesPeriod.week => (dstr(now.subtract(const Duration(days: 6))), t),
      SalesPeriod.month => ('${t.substring(0, 7)}-01', t),
      SalesPeriod.range => (from ?? t, to ?? t),
      SalesPeriod.all => (null, null),
    };
  }

  bool contains(String day) {
    final (a, b) = range;
    return (a == null || day.compareTo(a) >= 0) && (b == null || day.compareTo(b) <= 0);
  }
}

final salesFilterProvider = NotifierProvider<ValueHolder<SalesFilter>, SalesFilter>(() => ValueHolder(const SalesFilter()));

class SalesController extends ListController<Sale> {
  @override
  Future<List<Sale>> build() {
    ref.watch(salesFilterProvider);
    return super.build();
  }

  @override
  Future<List<Sale>> load() async {
    if (!ref.read(canViewSalesProvider)) return [];
    // 7 din ka chart hamesha chahiye, isliye kam se kam pichhle 7 din laao.
    final (a, b) = ref.read(salesFilterProvider).range;
    final weekStart = dstr(DateTime.now().subtract(const Duration(days: 6)));
    final from = a == null ? null : (a.compareTo(weekStart) < 0 ? a : weekStart);
    final to = (b != null && b.compareTo(today()) > 0) ? b : null;
    return repo.loadSales(from: from, to: to);
  }
}

final salesProvider = AsyncNotifierProvider<SalesController, List<Sale>>(SalesController.new);

// ---------------- bills ----------------
class BillsController extends ListController<Bill> {
  @override
  Future<List<Bill>> load() async => ref.read(isAdminProvider) ? repo.loadBills() : <Bill>[];
}

final billsProvider = AsyncNotifierProvider<BillsController, List<Bill>>(BillsController.new);

// ---------------- stock ----------------
class StockController extends ListController<StockItem> {
  @override
  Future<List<StockItem>> load() => repo.loadStock();
}

final stockProvider = AsyncNotifierProvider<StockController, List<StockItem>>(StockController.new);

/// 'all' | 'low' | 'out'
final stockFilterProvider = NotifierProvider<ValueHolder<String>, String>(() => ValueHolder('all'));

// ---------------- staff ----------------
class StaffController extends ListController<Profile> {
  @override
  Future<List<Profile>> load() async => ref.read(isAdminProvider) ? repo.loadStaff() : <Profile>[];
}

final staffProvider = AsyncNotifierProvider<StaffController, List<Profile>>(StaffController.new);

/// Sab kuch dobara laao (pull-to-refresh, app resume, har 60 sec).
Future<void> refreshAll(WidgetRef ref) async {
  await Future.wait([
    ref.read(repairsProvider.notifier).refresh(),
    ref.read(salesProvider.notifier).refresh(),
    ref.read(billsProvider.notifier).refresh(),
    ref.read(stockProvider.notifier).refresh(),
    ref.read(staffProvider.notifier).refresh(),
  ]);
}
