import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/sheet.dart';
import '../../../../core/widgets/ui.dart';
import 'repair_detail_widget.dart';

/// Naya repair ya edit (Admin).
Future<void> openRepairForm(BuildContext context, {Repair? repair}) {
  return showAppSheet(
    context,
    title: repair == null ? 'Naya repair' : 'Edit ${repair.code}',
    builder: (_) => RepairFormWidget(repair: repair, rootContext: context),
  );
}

class RepairFormWidget extends HookConsumerWidget {
  const RepairFormWidget({super.key, this.repair, required this.rootContext});
  final Repair? repair;
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = repair;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final mobile = useTextEditingController();
    final name = useTextEditingController();
    final custHint = useState<String?>(null);
    final model = useTextEditingController(text: r?.deviceModel ?? '');
    final imei = useTextEditingController(text: r?.imei ?? '');
    final problem = useTextEditingController(text: r?.problem ?? '');
    final est = useTextEditingController(text: r?.estimatedCharge?.round().toString() ?? '');
    final adv = useTextEditingController(text: (r?.advancePaid ?? 0) > 0 ? r!.advancePaid.round().toString() : '');
    final fin = useTextEditingController(text: r?.finalCharge?.round().toString() ?? '');
    final warr = useTextEditingController(text: r?.warrantyDays?.toString() ?? '');
    final lock = useTextEditingController(text: r?.lockCode ?? '');
    final pub = useTextEditingController(text: r?.publicNote ?? '');
    final internal = useTextEditingController(text: r?.internalNote ?? '');
    final received = useState<String?>(r?.receivedDate ?? today());
    final due = useState<String?>(r?.estimatedDelivery);
    final status = useState(repairStatuses.first.key);
    final acc = useState<Set<String>>({...?r?.accessories});
    final cond = useState<Set<String>>({...?r?.conditionChecks});

    Future<void> onMobile(String v) async {
      custHint.value = null;
      if (v.length != 10) return;
      try {
        final n = await ref.read(repositoryProvider).lookupCustomer(v);
        if (!context.mounted) return;
        if (n != null) {
          name.text = n;
          custHint.value = 'Purana customer: $n';
        } else {
          custHint.value = 'Naya customer';
        }
      } catch (_) {}
    }

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final im = imei.text.replaceAll(RegExp(r'\s'), '');
      if (im.isNotEmpty && !RegExp(r'^\d{14,16}$').hasMatch(im)) {
        showToast(context, 'IMEI 14-16 digit ka hona chahiye.', error: true);
        return;
      }
      final o = <String, dynamic>{
        'device_model': model.text.trim(),
        'problem': clean(problem.text),
        'imei': im.isEmpty ? null : im,
        'estimated_charge': numOrNull(est.text),
        'advance_paid': toNum(adv.text),
        'received_date': received.value ?? today(),
        'estimated_delivery': due.value,
        'lock_code': clean(lock.text),
        'accessories': acc.value.toList(),
        'condition_checks': cond.value.toList(),
        'public_note': clean(pub.text),
        'internal_note': clean(internal.text),
      };
      final repo = ref.read(repositoryProvider);
      final nav = Navigator.of(context);
      if (r != null) {
        o['final_charge'] = numOrNull(fin.text);
        o['warranty_days'] = numOrNull(warr.text);
        final ok = await runAction(context, () => repo.updateRepair(r.id, o), ok: 'Repair update ho gaya');
        if (ok) {
          await ref.read(repairsProvider.notifier).refresh();
          nav.pop();
        }
      } else {
        final m = digitsOnly(mobile.text);
        if (m.length != 10) {
          showToast(context, 'Mobile number 10 digit ka hona chahiye.', error: true);
          return;
        }
        o['status'] = status.value;
        String? newId;
        final ok = await runAction(context, () async {
          final (id, code) = await repo.createRepair(mobile: m, name: name.text.trim(), data: o);
          newId = id;
          if (context.mounted) showToast(context, 'Repair $code ban gaya');
        });
        if (ok) {
          await ref.read(repairsProvider.notifier).refresh();
          nav.pop();
          if (newId != null && rootContext.mounted) openRepairDetail(rootContext, newId!);
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (r != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NoteBox('Customer: ${r.customerName ?? ''} · ${r.customerMobile ?? ''} (customer badla nahi ja sakta)',
                  icon: Icons.person_outline_rounded, color: AppColors.gold),
            )
          else ...[
            FieldRow([
              Field(
                label: 'Customer mobile',
                controller: mobile,
                digitsOnly: true,
                maxLength: 10,
                required: true,
                hint: '10 digit',
                helper: custHint.value,
                onChanged: onMobile,
                autofill: const [AutofillHints.telephoneNumber],
              ),
              Field(label: 'Customer naam', controller: name, required: true),
            ]),
          ],
          FieldRow([
            Field(label: 'Phone model', controller: model, required: true, hint: 'Jaise: Redmi Note 12'),
            Field(label: 'IMEI', controller: imei, digitsOnly: true, maxLength: 16),
          ]),
          Field(label: 'Problem', controller: problem, hint: 'Jaise: Display toota, charging nahi'),
          FieldRow([
            Field(label: 'Estimate (₹)', controller: est, digitsOnly: true),
            Field(label: 'Advance liya (₹)', controller: adv, digitsOnly: true),
          ]),
          FieldRow([
            DateField(label: 'Jama date', value: received.value, onChanged: (v) => received.value = v),
            DateField(label: 'Dene ki date', value: due.value, allowClear: true, onChanged: (v) => due.value = v),
          ]),
          if (r != null)
            FieldRow([
              Field(label: 'Final charge (₹)', controller: fin, digitsOnly: true),
              Field(label: 'Warranty (din)', controller: warr, digitsOnly: true, maxLength: 3),
            ])
          else
            DropdownField<String>(
              label: 'Status',
              value: status.value,
              items: [for (final s in repairStatuses.take(4)) s.key],
              itemLabel: (k) => statusOf(k).label,
              onChanged: (v) => status.value = v,
            ),
          Field(label: 'Lock / password', controller: lock, maxLength: 40),
          CheckChips(label: 'Saath me aaya', options: accessories, selected: acc.value, onChanged: (v) => acc.value = v),
          CheckChips(label: 'Phone ki halat', options: conditions, selected: cond.value, onChanged: (v) => cond.value = v),
          Field(label: 'Customer ke liye note', controller: pub, helper: 'Track page par customer ko dikhega'),
          Field(label: 'Andar ka note', controller: internal, maxLines: 3, helper: 'Sirf shop ke liye'),
          SheetActions(primary: BusyButton(label: r == null ? 'Repair banao' : 'Save karein', icon: Icons.check_rounded, onPressed: submit)),
        ],
      ),
    );
  }
}
