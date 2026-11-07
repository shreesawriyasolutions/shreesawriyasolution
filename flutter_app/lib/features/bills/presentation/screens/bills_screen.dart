import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/csv.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/ui.dart';
import '../widgets/bill_detail_widget.dart';
import '../widgets/bill_form_widget.dart';

class BillsScreen extends HookConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(isAdminProvider);
    final bills = ref.watch(billsProvider);
    final type = useState<String>('');
    final query = useState('');

    final header = PageHeader(
      title: 'Bills register',
      subtitle: 'Kharid, bikri aur unlocking ke bill photo/PDF ke saath',
      action: FilledButton.icon(onPressed: () => openBillForm(context), icon: const Icon(Icons.upload_rounded), label: const Text('Upload')),
    );

    if (!admin) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          header,
          const NoteBox('Staff mode: aap bill upload kar sakte hain. Uploaded bills ki list sirf Admin dekh sakta hai.'),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton.icon(onPressed: () => openBillForm(context), icon: const Icon(Icons.cloud_upload_rounded), label: const Text('Bill upload karo')),
          ),
        ],
      );
    }

    final all = bills.value ?? const <Bill>[];
    final q = query.value.trim().toLowerCase();
    final list = all.where((b) => type.value.isEmpty || b.billType == type.value).where((b) => q.isEmpty || b.searchText.contains(q)).take(400).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(billsProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          header,
          TwoColGrid(children: [
            for (final t in billTypes)
              KpiTile(
                label: t.label,
                value: inr(sumOf(all.where((b) => b.billType == t.value), (b) => b.amount)),
                sub: '${all.where((b) => b.billType == t.value).length} bills',
                color: AppColors.tone(t.tone),
                selected: type.value == t.value,
                onTap: () => type.value = type.value == t.value ? '' : t.value,
              ),
            KpiTile(
              label: 'Sab bills',
              value: inr(sumOf(all, (b) => b.amount)),
              sub: '${all.length} bills',
              selected: type.value.isEmpty,
              onTap: () => type.value = '',
            ),
          ]),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: AppSearchField(hint: 'Party, mobile, IMEI, model', onChanged: (v) => query.value = v)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'CSV download',
                onPressed: () async {
                  if (list.isEmpty) {
                    showToast(context, 'Download ke liye koi bill nahi.', error: true);
                    return;
                  }
                  await runAction(
                    context,
                    () => shareCsv(
                      'bills-register-${today()}.csv',
                      ['Date', 'Type', 'Party', 'Mobile', 'Model', 'IMEI', 'Kaam', 'Amount', 'Notes', 'Uploaded By'],
                      [for (final b in list) [b.billDate, b.billType, b.partyName, b.mobile, b.phoneModel, b.imei, b.workType, b.amount, b.notes, b.uploadedBy]],
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (bills.hasError && !bills.hasValue)
            ErrorBlock(message: friendlyError(bills.error), onRetry: () => ref.read(billsProvider.notifier).refresh())
          else if (!bills.hasValue)
            const LoadingBlock()
          else if (list.isEmpty)
            const EmptyState(title: 'Koi bill nahi mila', message: 'Type card dobara dabakar sab bills dekhein.', icon: Icons.receipt_long_outlined)
          else
            for (var i = 0; i < list.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BillTile(bill: list[i], onTap: () => openBillDetail(context, list[i])).entry(i),
              ),
        ],
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({required this.bill, required this.onTap});
  final Bill bill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = bill;
    final t = billTypeOf(b.billType);
    final c = AppColors.tone(t.tone);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
            child: Icon(
              switch (b.billType) {
                'Sale Bill' => Icons.sell_rounded,
                'Unlocking Job' => Icons.lock_open_rounded,
                _ => Icons.shopping_bag_rounded,
              },
              color: c,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.partyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                Text(
                  [fmtDate(b.billDate), b.uploadedBy, if (b.phoneModel != null) b.phoneModel!].join(' · '),
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
              if (b.amount != null) Text(inr(b.amount), style: AppTheme.number(size: 17)),
              const SizedBox(height: 4),
              Pill(t.label, tone: t.tone, dot: false),
            ],
          ),
        ],
      ),
    );
  }
}
