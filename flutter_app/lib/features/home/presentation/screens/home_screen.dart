import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/ui.dart';
import '../../../bills/presentation/widgets/bill_form_widget.dart';
import '../../../repairs/presentation/widgets/repair_card_widget.dart';
import '../../../repairs/presentation/widgets/repair_detail_widget.dart';
import '../../../repairs/presentation/widgets/repair_form_widget.dart';
import '../../../sales/presentation/widgets/sale_form_widget.dart';
import '../../../stock/presentation/widgets/stock_card_widget.dart';
import '../../../stock/presentation/widgets/stock_detail_widget.dart';
import '../../../stock/presentation/widgets/stock_form_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider);
    final admin = me?.isAdmin ?? false;
    final canView = ref.watch(canViewSalesProvider);
    final repairsAsync = ref.watch(repairsProvider);
    final repairs = repairsAsync.value ?? const <Repair>[];
    final sales = ref.watch(salesProvider).value ?? const <Sale>[];
    final stock = ref.watch(stockProvider).value ?? const <StockItem>[];

    final t = today();
    final open = repairs.where((r) => r.isOpen).toList();
    final ready = repairs.where((r) => r.status == 'Ready for Pickup').toList();
    final waiting = repairs.where((r) => r.status == 'Waiting for Part').toList();
    final todaySales = sales.where((s) => s.entryDate == t).toList();
    final low = stock.where((i) => i.state != StockState.ok).toList();

    void goRepairs(String f) {
      ref.read(repairFilterProvider.notifier).set(f);
      context.goTab('/status');
    }

    return RefreshIndicator(
      onRefresh: () => refreshAll(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text('Namaste, ${me?.name ?? 'Staff'} 🙏', style: AppTheme.head(size: 27)).animate().fadeIn(duration: 350.ms),
          const SizedBox(height: 2),
          Text('${longToday()} · ${admin ? 'Admin mode: sab kuch control' : 'Staff mode'}', style: const TextStyle(color: AppColors.muted, fontSize: 14.5)),
          const SizedBox(height: 16),
          if (canView)
            HeroKpi(
              label: 'Aaj ki sale',
              value: inr(sumOf(todaySales, (s) => s.amount)),
              sub: '${todaySales.length} entries · profit ${inr(sumOf(todaySales, (s) => s.profit ?? (s.amount - s.expense)))}',
              icon: Icons.payments_rounded,
              onTap: () => context.goTab('/sales'),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: .05, end: 0)
          else
            HeroKpi(
              label: 'Chalu repairs',
              value: '${open.length}',
              sub: 'abhi shop me',
              icon: Icons.build_circle_rounded,
              onTap: () => goRepairs('open'),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: .05, end: 0),
          const SizedBox(height: 10),
          TwoColGrid(children: [
            if (canView)
              KpiTile(label: 'Chalu repairs', value: '${open.length}', sub: '${waiting.length} part ke wait me', icon: Icons.build_rounded, onTap: () => goRepairs('open'))
            else
              KpiTile(label: 'Part ka wait', value: '${waiting.length}', sub: 'repairs', icon: Icons.hourglass_top_rounded, onTap: () => goRepairs('Waiting for Part')),
            KpiTile(
              label: 'Pickup ready',
              value: '${ready.length}',
              sub: 'customer ko bulao',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.green,
              onTap: () => goRepairs('Ready for Pickup'),
            ),
            KpiTile(
              label: 'Stock alert',
              value: '${low.length}',
              sub: 'kam ya khatam items',
              icon: Icons.warning_amber_rounded,
              color: low.isEmpty ? null : AppColors.amber,
              onTap: () {
                ref.read(stockFilterProvider.notifier).set('low');
                context.goTab('/stock');
              },
            ),
            if (canView)
              KpiTile(
                label: 'Aaj ka kharcha',
                value: inr(sumOf(todaySales, (s) => s.expense)),
                sub: 'parts / expense',
                icon: Icons.south_west_rounded,
                color: AppColors.red,
              ),
          ]),
          const SizedBox(height: 18),
          Row(
            children: [
              _QuickAction(icon: Icons.add_to_home_screen_rounded, label: 'Naya repair', onTap: () => openRepairForm(context)),
              _QuickAction(icon: Icons.add_chart_rounded, label: 'Sale entry', onTap: () => openSaleForm(context)),
              _QuickAction(icon: Icons.document_scanner_rounded, label: 'Bill upload', onTap: () => openBillForm(context)),
              _QuickAction(icon: Icons.add_box_rounded, label: 'Stock add', onTap: () => openStockForm(context)),
            ],
          ),
          SectionHeader('Pickup ke liye ready', actionLabel: 'Sab dekho', onAction: () => goRepairs('Ready for Pickup')),
          if (!repairsAsync.hasValue)
            const LoadingBlock(count: 2)
          else if (ready.isEmpty)
            const EmptyState(title: 'Abhi koi phone ready nahi', message: 'Status "Ready" karte hi yahan dikhega.', icon: Icons.check_circle_outline_rounded)
          else
            for (final (i, r) in ready.take(4).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RepairCardWidget(repair: r, onTap: () => openRepairDetail(context, r.id)).entry(i),
              ),
          SectionHeader('Chalu repairs', actionLabel: 'Status kholo', onAction: () => goRepairs('open')),
          if (!repairsAsync.hasValue)
            const LoadingBlock(count: 2)
          else if (open.isEmpty)
            const EmptyState(title: 'Koi chalu repair nahi', icon: Icons.phone_android_outlined)
          else
            for (final (i, r) in open.take(6).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RepairCardWidget(repair: r, onTap: () => openRepairDetail(context, r.id)).entry(i),
              ),
          if (low.isNotEmpty) ...[
            SectionHeader('Stock khatam / kam', actionLabel: 'Stock kholo', onAction: () {
              ref.read(stockFilterProvider.notifier).set('low');
              context.goTab('/stock');
            }),
            for (final (i, it) in low.take(4).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StockCardWidget(item: it, showBuy: admin, onTap: () => openStockDetail(context, it)).entry(i),
              ),
          ],
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: .12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: .35)),
                    ),
                    child: Icon(icon, color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
