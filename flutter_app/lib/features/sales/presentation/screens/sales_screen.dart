import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/csv.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/ui.dart';
import '../widgets/sale_detail_widget.dart';
import '../widgets/sale_form_widget.dart';

const _periodLabels = {
  SalesPeriod.today: 'Aaj',
  SalesPeriod.week: '7 din',
  SalesPeriod.month: 'Is mahine',
  SalesPeriod.all: 'Sab',
  SalesPeriod.range: 'Date range',
};

class SalesScreen extends HookConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(canViewSalesProvider);
    final admin = ref.watch(isAdminProvider);
    final sales = ref.watch(salesProvider);
    final filter = ref.watch(salesFilterProvider);
    final query = useState('');

    final header = PageHeader(
      title: 'Daily sales',
      subtitle: 'Har sale ki entry, parts stock se apne aap kam honge',
      action: FilledButton.icon(onPressed: () => openSaleForm(context), icon: const Icon(Icons.add_rounded), label: const Text('Entry')),
    );

    if (!canView) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          header,
          const NoteBox('Staff mode: aap nayi sale entry kar sakte hain. Sales ki list sirf Admin (ya jinhe Admin ne permission di) dekh sakte hain.'),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton.icon(onPressed: () => openSaleForm(context), icon: const Icon(Icons.add_chart_rounded), label: const Text('Sale entry karo')),
          ),
        ],
      );
    }

    final all = sales.value ?? const <Sale>[];
    final q = query.value.trim().toLowerCase();
    final list = all.where((s) => filter.contains(s.entryDate)).where((s) => q.isEmpty || s.searchText.contains(q)).toList();
    final rec = sumOf(list, (s) => s.amount), exp = sumOf(list, (s) => s.expense);
    final byPay = <String, double>{};
    final byStaff = <String, double>{};
    for (final s in list) {
      byPay[s.paymentMode] = (byPay[s.paymentMode] ?? 0) + s.amount;
      byStaff[s.staffName] = (byStaff[s.staffName] ?? 0) + s.amount;
    }
    final now = DateTime.now();
    final days = [
      for (var i = 6; i >= 0; i--)
        () {
          final d = now.subtract(Duration(days: i));
          final k = dstr(d);
          return (k, i == 0 ? 'Aaj' : weekdayShort(d), sumOf(all.where((s) => s.entryDate == k), (s) => s.amount));
        }(),
    ];

    Future<void> pickRange() async {
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        initialDateRange: filter.from != null && filter.to != null
            ? DateTimeRange(start: DateTime.parse(filter.from!), end: DateTime.parse(filter.to!))
            : null,
      );
      if (r == null) return;
      ref.read(salesFilterProvider.notifier).set(SalesFilter(period: SalesPeriod.range, from: dstr(r.start), to: dstr(r.end)));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(salesProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          header,
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in SalesPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      showCheckmark: false,
                      selected: filter.period == p,
                      label: Text(
                        p == SalesPeriod.range && filter.period == p ? '${fmtDate(filter.from)} – ${fmtDate(filter.to)}' : _periodLabels[p]!,
                        style: TextStyle(color: filter.period == p ? AppColors.gold : AppColors.fg, fontWeight: FontWeight.w600),
                      ),
                      onSelected: (_) => p == SalesPeriod.range
                          ? pickRange()
                          : ref.read(salesFilterProvider.notifier).set(SalesFilter(period: p)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (sales.hasError && !sales.hasValue)
            ErrorBlock(message: friendlyError(sales.error), onRetry: () => ref.read(salesProvider.notifier).refresh())
          else if (!sales.hasValue)
            const LoadingBlock()
          else ...[
            HeroKpi(label: 'Total received', value: inr(rec), sub: '${list.length} entries · ${_periodLabels[filter.period]}', icon: Icons.payments_rounded),
            const SizedBox(height: 10),
            TwoColGrid(children: [
              KpiTile(label: 'Kharcha', value: inr(exp), sub: 'parts / expense', icon: Icons.south_west_rounded, color: AppColors.red),
              KpiTile(label: 'Profit', value: inr(rec - exp), sub: 'received − kharcha', icon: Icons.north_east_rounded, color: AppColors.green),
              KpiTile(label: 'Cash', value: inr(byPay['Cash'] ?? 0), sub: 'naqad', icon: Icons.money_rounded),
              KpiTile(label: 'UPI / Card', value: inr((byPay['UPI'] ?? 0) + (byPay['Card'] ?? 0)), sub: 'Card ${inr(byPay['Card'] ?? 0)}', icon: Icons.qr_code_2_rounded),
            ]),
            const SectionHeader('Pichhle 7 din'),
            _WeekBars(days: days),
            const SectionHeader('Staff ke hisaab se'),
            _HBars(data: byStaff),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: AppSearchField(hint: 'Kaam, customer ya staff', onChanged: (v) => query.value = v)),
                if (admin) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'CSV download',
                    onPressed: () async {
                      if (list.isEmpty) {
                        showToast(context, 'Download ke liye koi entry nahi.', error: true);
                        return;
                      }
                      await runAction(
                        context,
                        () => shareCsv(
                          'daily-sales-${today()}.csv',
                          ['Date', 'Kaam', 'Customer', 'Amount', 'Kharcha', 'Profit', 'Payment', 'Staff', 'Notes'],
                          [for (final s in list) [s.entryDate, s.description, s.customerName, s.amount, s.expense, s.profit, s.paymentMode, s.staffName, s.notes]],
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const EmptyState(title: 'Is period me koi sale nahi', message: 'Upar se period badlein ya nayi entry karein.', icon: Icons.bar_chart_rounded)
            else
              for (var i = 0; i < list.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SaleTile(sale: list[i], onTap: () => openSaleDetail(context, list[i])).entry(i),
                ),
          ],
        ],
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale, required this.onTap});
  final Sale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = sale;
    final icon = switch (s.paymentMode) {
      'UPI' => Icons.qr_code_2_rounded,
      'Card' => Icons.credit_card_rounded,
      'Cash' => Icons.money_rounded,
      _ => Icons.payments_outlined,
    };
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                Text(
                  [s.paymentMode, s.staffName, if (s.customerName != null && s.customerName!.isNotEmpty) s.customerName!].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(inr(s.amount), style: AppTheme.number(size: 18, color: AppColors.fg)),
              Text(
                '${s.expense > 0 ? 'Kharcha ${inr(s.expense)} · ' : ''}${fmtDate(s.entryDate)}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.days});
  final List<(String, String, double)> days;

  @override
  Widget build(BuildContext context) {
    final maxV = math.max(1.0, days.map((d) => d.$3).fold<double>(0, math.max));
    return Container(
      height: 210,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppColors.line)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (d.$3 > 0)
                      FittedBox(
                        child: Text(
                          d.$3 >= 1000 ? '${(d.$3 / 1000).toStringAsFixed(1)}k' : d.$3.round().toString(),
                          style: TextStyle(fontSize: 11, color: d.$2 == 'Aaj' ? AppColors.gold : AppColors.muted, fontWeight: FontWeight.w700),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: math.max(.03, d.$3 / maxV),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, _) => FractionallySizedBox(
                            heightFactor: v,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(3)),
                                gradient: d.$2 == 'Aaj'
                                    ? AppColors.goldGradient
                                    : LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [AppColors.silver.withValues(alpha: .5), AppColors.silver.withValues(alpha: .15)],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(d.$2, style: TextStyle(fontSize: 12, color: d.$2 == 'Aaj' ? AppColors.gold : AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HBars extends StatelessWidget {
  const _HBars({required this.data});
  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final e = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (e.isEmpty) return const Text('Is period me koi sale nahi.', style: TextStyle(color: AppColors.muted));
    final m = math.max(1.0, e.first.value);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppColors.line)),
      child: Column(
        children: [
          for (final x in e)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 84, child: Text(x.key.isEmpty ? '—' : x.key, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Stack(
                        children: [
                          Container(height: 10, color: AppColors.surface3),
                          FractionallySizedBox(
                            widthFactor: x.value / m,
                            child: Container(height: 10, decoration: const BoxDecoration(gradient: AppColors.goldGradient)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(width: 78, child: Text(inr(x.value), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
