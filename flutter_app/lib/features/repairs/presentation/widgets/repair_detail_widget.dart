import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
import '../../../sales/presentation/widgets/sale_form_widget.dart';
import 'repair_form_widget.dart';

Future<void> openRepairDetail(BuildContext context, String id) {
  final r = ProviderScope.containerOf(context).read(repairsProvider).value?.where((x) => x.id == id).firstOrNull;
  return showAppSheet(
    context,
    title: r == null ? 'Repair' : '${r.code} · ${r.customerName ?? ''}',
    builder: (_) => RepairDetailWidget(id: id, rootContext: context),
  );
}

class RepairDetailWidget extends HookConsumerWidget {
  const RepairDetailWidget({super.key, required this.id, required this.rootContext});
  final String id;
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(repairsProvider).value?.where((x) => x.id == id).firstOrNull;
    final isAdmin = ref.watch(isAdminProvider);
    final staff = ref.watch(staffProvider).value ?? const <Profile>[];
    final me = ref.watch(profileProvider);
    final repo = ref.watch(repositoryProvider);
    final historyFuture = useMemoized(() => repo.repairHistory(id), [r?.status, r?.updatedAt]);
    final history = useFuture(historyFuture);
    final busyStatus = useState<String?>(null);

    if (r == null) return const EmptyState(title: 'Repair nahi mila', message: 'Shayad delete ho gaya.');

    final fi = repairFlow.indexOf(r.status);
    final names = {for (final p in staff) p.id: p.name, if (me != null) me.id: me.name};
    final waText = 'Namaste ${r.customerName ?? ''} ji, Shree Sawriya Solutions se. Aapke ${r.deviceModel} (${r.code}) ka status: '
        '${statusOf(r.status).label}.${r.publicNote != null ? ' ${r.publicNote}' : ''} Track karein: ${AppConfig.site}/track.html';

    Future<void> setStatus(String s) async {
      busyStatus.value = s;
      await runAction(context, () async {
        await repo.setRepairStatus(r.id, s);
        await ref.read(repairsProvider.notifier).refresh();
      }, ok: 'Status: ${statusOf(s).label}');
      if (context.mounted) busyStatus.value = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            StatusPill(r.status),
            const Spacer(),
            Text('Update: ${fmtTime(r.updatedAt)}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ],
        ),
        if (r.status != 'Returned') ...[
          const SizedBox(height: 18),
          _FlowStepper(current: fi),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold.withValues(alpha: .3)),
            color: AppColors.gold.withValues(alpha: .06),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Baaki lena hai', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    Text(inr(r.due), style: AppTheme.number(size: 28, color: AppColors.gold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (r.estimatedCharge != null) Text('Est. ${inr(r.estimatedCharge)}', style: const TextStyle(color: AppColors.muted)),
                  if (r.finalCharge != null) Text('Final ${inr(r.finalCharge)}', style: const TextStyle(color: AppColors.fg)),
                  if (r.advancePaid > 0) Text('Advance ${inr(r.advancePaid)}', style: const TextStyle(color: AppColors.green)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        KvList([
          ('Customer', '${r.customerName ?? ''} · ${r.customerMobile ?? ''}'),
          ('Phone', '${r.deviceModel}${r.imei != null ? ' · IMEI ${r.imei}' : ''}'),
          if (r.problem != null) ('Problem', r.problem!),
          ('Jama date', '${fmtDate(r.receivedDate)}${r.estimatedDelivery != null ? ' · Dena: ${fmtDate(r.estimatedDelivery)}' : ''}'),
          if (r.lockCode != null) ('Lock', r.lockCode!),
          if (r.accessories.isNotEmpty) ('Saath me', r.accessories.join(', ')),
          if (r.conditionChecks.isNotEmpty) ('Halat', r.conditionChecks.join(', ')),
          if (r.publicNote != null) ('Customer note', r.publicNote!),
          if (r.internalNote != null) ('Andar ka note', r.internalNote!),
          if (r.deliveredOn != null)
            ('Delivered', '${fmtDate(r.deliveredOn)}${r.warrantyDays != null && r.warrantyDays! > 0 ? ' · ${r.warrantyDays} din warranty' : ''}'),
        ]),
        const SectionHeader('Status badlo'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in repairStatuses.where((s) => s.key != r.status))
              ActionChip(
                onPressed: busyStatus.value != null ? null : () => setStatus(s.key),
                avatar: busyStatus.value == s.key
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.circle, size: 10, color: AppColors.tone(s.tone)),
                label: Text(s.label),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (r.customerMobile != null)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.green, side: BorderSide(color: AppColors.green.withValues(alpha: .4))),
                  onPressed: () => launchUrl(
                    Uri.parse('https://wa.me/91${r.customerMobile}?text=${Uri.encodeComponent(waText)}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('WhatsApp'),
                ),
              ),
            if (r.customerMobile != null) const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  openSaleForm(rootContext, prefill: SalePrefill.fromRepair(r));
                },
                icon: const Icon(Icons.add_chart_rounded),
                label: const Text('Sale entry'),
              ),
            ),
          ],
        ),
        if (r.customerMobile != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse('tel:${r.customerMobile}')),
            icon: const Icon(Icons.call_rounded),
            label: Text('Call ${r.customerMobile}'),
          ),
        ],
        const SectionHeader('History'),
        if (history.connectionState != ConnectionState.done)
          const LinearProgressIndicator(minHeight: 2)
        else if (history.hasError)
          const Text('History load nahi hui', style: TextStyle(color: AppColors.muted))
        else
          Timeline([
            for (final h in history.data ?? const <StatusHistory>[])
              TimelineItem(
                title: '${statusOf(h.status).label}${names[h.changedBy] != null ? ' · ${names[h.changedBy]}' : ''}',
                sub: fmtTime(h.changedAt),
                color: AppColors.tone(statusOf(h.status).tone),
              ),
          ]),
        const SizedBox(height: 14),
        if (isAdmin)
          Row(
            children: [
              Expanded(
                child: ConfirmDeleteButton(
                  what: 'Yeh repair (history ke saath)',
                  onConfirm: () async {
                    final nav = Navigator.of(context);
                    final ok = await runAction(context, () => repo.delete(DeleteKind.repair, r.id), ok: 'Delete ho gaya');
                    if (ok) {
                      nav.pop();
                      await ref.read(repairsProvider.notifier).refresh();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openRepairForm(rootContext, repair: r);
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ),
            ],
          )
        else
          const NoteBox('Staff mode: aap status badal sakte hain. Baaki details Admin badlega.'),
      ],
    );
  }
}

class _FlowStepper extends StatelessWidget {
  const _FlowStepper({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < repairFlow.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container(height: 2, color: i == 0 ? Colors.transparent : (current >= i ? AppColors.gold : AppColors.line))),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: current >= i ? AppColors.goldGradient : null,
                        color: current >= i ? null : AppColors.surface2,
                        border: Border.all(color: current == i ? AppColors.goldLight : AppColors.line, width: current == i ? 2 : 1),
                      ),
                      child: Icon(current > i ? Icons.check_rounded : Icons.circle, size: current > i ? 16 : 8,
                          color: current >= i ? AppColors.goldInk : AppColors.muted),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == repairFlow.length - 1 ? Colors.transparent : (current > i ? AppColors.gold : AppColors.line),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  statusOf(repairFlow[i]).label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: current == i ? FontWeight.w800 : FontWeight.w500, color: current >= i ? AppColors.fg : AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
