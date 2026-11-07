import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/ui.dart';
import '../widgets/stock_card_widget.dart';
import '../widgets/stock_detail_widget.dart';
import '../widgets/stock_form_widget.dart';

class StockScreen extends HookConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(isAdminProvider);
    final stock = ref.watch(stockProvider);
    final filter = ref.watch(stockFilterProvider);
    final cat = useState('');
    final query = useState('');

    final all = stock.value ?? const <StockItem>[];
    final q = query.value.trim().toLowerCase();
    final list = all
        .where((i) => filter == 'all' || (filter == 'low' ? i.state != StockState.ok : i.state == StockState.out))
        .where((i) => cat.value.isEmpty || i.category == cat.value)
        .where((i) => q.isEmpty || i.searchText.contains(q))
        .take(400)
        .toList();
    final low = all.where((i) => i.state == StockState.low).length;
    final out = all.where((i) => i.state == StockState.out).length;
    void setFilter(String f) => ref.read(stockFilterProvider.notifier).set(f);

    return RefreshIndicator(
      onRefresh: () => ref.read(stockProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          PageHeader(
            title: 'Stock',
            subtitle: admin ? 'Parts, accessories aur mobiles ka hisaab' : 'Staff mode: naya maal jod sakte hain, kam sirf Admin karega',
            action: FilledButton.icon(onPressed: () => openStockForm(context), icon: const Icon(Icons.add_rounded), label: const Text('Add')),
          ),
          TwoColGrid(children: [
            KpiTile(
              label: 'Items',
              value: '${all.length}',
              sub: '${sumOf(all, (i) => i.quantity).round()} pcs',
              icon: Icons.inventory_2_outlined,
              selected: filter == 'all',
              onTap: () => setFilter('all'),
            ),
            KpiTile(
              label: 'Kam stock',
              value: '${low + out}',
              sub: 'min se kam ya khatam',
              icon: Icons.warning_amber_rounded,
              color: AppColors.amber,
              selected: filter == 'low',
              onTap: () => setFilter('low'),
            ),
            KpiTile(
              label: 'Khatam',
              value: '$out',
              sub: '0 pcs',
              icon: Icons.remove_shopping_cart_outlined,
              color: AppColors.red,
              selected: filter == 'out',
              onTap: () => setFilter('out'),
            ),
            if (admin)
              KpiTile(
                label: 'Stock value',
                value: inr(sumOf(all, (i) => i.quantity * (i.purchasePrice ?? 0))),
                sub: 'kharid rate se',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.gold,
              ),
          ]),
          const SizedBox(height: 14),
          AppSearchField(hint: 'Part, brand, model, supplier', onChanged: (v) => query.value = v),
          const SizedBox(height: 10),
          ChipBar<String>(
            items: ['', ...stockCategories],
            selected: cat.value,
            onSelect: (v) => cat.value = v,
            label: (c) => c.isEmpty ? 'Sab category' : c,
          ),
          const SizedBox(height: 12),
          if (stock.hasError && !stock.hasValue)
            ErrorBlock(message: friendlyError(stock.error), onRetry: () => ref.read(stockProvider.notifier).refresh())
          else if (!stock.hasValue)
            const LoadingBlock()
          else if (list.isEmpty)
            const EmptyState(title: 'Koi item nahi mila', message: 'Search ya filter badlein.', icon: Icons.inventory_2_outlined)
          else
            for (var i = 0; i < list.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StockCardWidget(item: list[i], showBuy: admin, onTap: () => openStockDetail(context, list[i])).entry(i),
              ),
        ],
      ),
    );
  }
}
