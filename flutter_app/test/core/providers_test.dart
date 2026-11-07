import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sss_shop/core/data/demo_shop_repository.dart';
import 'package:sss_shop/core/data/shop_repository.dart';
import 'package:sss_shop/core/errors/app_exception.dart';
import 'package:sss_shop/core/models/models.dart';
import 'package:sss_shop/core/providers/providers.dart';
import 'package:sss_shop/core/utils/format.dart';

class MockRepo extends Mock implements ShopRepository {}

void main() {
  group('SalesFilter', () {
    test('today range is a single day', () {
      const f = SalesFilter();
      expect(f.range, (today(), today()));
      expect(f.contains(today()), isTrue);
      expect(f.contains('2000-01-01'), isFalse);
    });

    test('all has no limits', () {
      const f = SalesFilter(period: SalesPeriod.all);
      expect(f.range, (null, null));
      expect(f.contains('2000-01-01'), isTrue);
    });

    test('custom range', () {
      const f = SalesFilter(period: SalesPeriod.range, from: '2026-01-01', to: '2026-01-31');
      expect(f.contains('2026-01-15'), isTrue);
      expect(f.contains('2026-02-01'), isFalse);
    });
  });

  group('controllers with demo data', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [repositoryProvider.overrideWithValue(DemoShopRepository())]);
      addTearDown(container.dispose);
    });

    test('session restores admin profile', () async {
      final p = await container.read(sessionProvider.future);
      expect(p?.isAdmin, isTrue);
      expect(container.read(isAdminProvider), isTrue);
    });

    test('repairs load after login and status change refreshes', () async {
      await container.read(sessionProvider.future);
      final list = await container.read(repairsProvider.future);
      expect(list, isNotEmpty);

      final repo = container.read(repositoryProvider);
      await repo.setRepairStatus(list.first.id, 'Delivered');
      await container.read(repairsProvider.notifier).refresh();
      final after = container.read(repairsProvider).value!;
      expect(after.firstWhere((r) => r.id == list.first.id).status, 'Delivered');
    });

    test('creating a sale with parts reduces stock', () async {
      await container.read(sessionProvider.future);
      final stock = await container.read(stockProvider.future);
      final item = stock.firstWhere((i) => i.quantity > 1);
      await container.read(repositoryProvider).createSale({'entry_date': today(), 'sale_description': 'Test', 'amount_received': 100, 'expense': 0, 'payment_mode': 'Cash', 'staff_name': 'A'}, [(item.id, 1)]);
      await container.read(stockProvider.notifier).refresh();
      final after = container.read(stockProvider).value!.firstWhere((i) => i.id == item.id);
      expect(after.quantity, item.quantity - 1);
    });

    test('demo stock cannot go below zero', () async {
      final repo = container.read(repositoryProvider);
      final out = (await repo.loadStock()).firstWhere((i) => i.quantity == 0);
      expect(() => repo.adjustStock(out.id, -1, 'Adjust', null), throwsA(isA<AppException>()));
    });
  });

  group('staff (non admin)', () {
    test('bills and staff lists stay empty, sales hidden without permission', () async {
      final repo = MockRepo();
      when(() => repo.restoreSession()).thenAnswer((_) async => const Profile(id: 's', role: 'staff', canView: false));
      when(() => repo.loadRepairs()).thenAnswer((_) async => <Repair>[]);
      final c = ProviderContainer(overrides: [repositoryProvider.overrideWithValue(repo)]);
      addTearDown(c.dispose);

      await c.read(sessionProvider.future);
      expect(await c.read(billsProvider.future), isEmpty);
      expect(await c.read(staffProvider.future), isEmpty);
      expect(await c.read(salesProvider.future), isEmpty);
      verifyNever(() => repo.loadBills());
      verifyNever(() => repo.loadStaff());
      verifyNever(() => repo.loadSales(from: any(named: 'from'), to: any(named: 'to')));
    });
  });

  test('friendlyError maps network and permission errors', () {
    expect(friendlyError(const AppException('Custom')), 'Custom');
    expect(friendlyError(Exception('SocketException: Failed host lookup')), contains('Internet'));
    expect(friendlyError(Exception('new row violates row-level security')), contains('permission'));
  });
}
