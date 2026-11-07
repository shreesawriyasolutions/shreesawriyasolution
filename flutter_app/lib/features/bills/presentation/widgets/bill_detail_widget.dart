import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config.dart';
import '../../../../core/data/shop_repository.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/sheet.dart';
import '../../../../core/widgets/ui.dart';

Future<void> openBillDetail(BuildContext context, Bill bill) =>
    showAppSheet(context, title: bill.partyName, builder: (_) => BillDetailWidget(bill: bill));

class BillDetailWidget extends ConsumerWidget {
  const BillDetailWidget({super.key, required this.bill});
  final Bill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = bill;
    final t = billTypeOf(b.billType);
    final repo = ref.watch(repositoryProvider);

    Future<void> view(String path) => runAction(context, () async {
          final url = await repo.signedFileUrl(path);
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Pill(t.label, tone: t.tone),
            const Spacer(),
            if (b.amount != null) Text(inr(b.amount), style: AppTheme.number(size: 26, color: AppColors.gold)),
          ],
        ),
        const SizedBox(height: 14),
        KvList([
          ('Date', fmtDate(b.billDate)),
          if (b.mobile != null) ('Mobile', b.mobile!),
          if (b.phoneModel != null) ('Model', b.phoneModel!),
          if (b.imei != null) ('IMEI', b.imei!),
          if (b.workType != null) ('Kaam', b.workType!),
          if (b.notes != null) ('Notes', b.notes!),
          ('Upload by', '${b.uploadedBy} · ${fmtTime(b.createdAt)}'),
        ]),
        const SectionHeader('Files'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in b.files)
              OutlinedButton.icon(
                onPressed: () => view(f.$1),
                icon: Icon(f.$1.endsWith('.pdf') ? Icons.picture_as_pdf_rounded : (f.$2.startsWith('ID') ? Icons.badge_rounded : Icons.receipt_rounded)),
                label: Text('${f.$2} dekho'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        ConfirmDeleteButton(
          what: 'Yeh bill aur uski files',
          label: 'Delete (files bhi)',
          onConfirm: () async {
            final nav = Navigator.of(context);
            final ok = await runAction(
              context,
              () => repo.delete(DeleteKind.bill, b.id, filePaths: [for (final f in b.files) f.$1]),
              ok: 'Delete ho gaya',
            );
            if (ok) {
              nav.pop();
              await ref.read(billsProvider.notifier).refresh();
            }
          },
        ),
      ],
    );
  }
}
