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

class SalePrefill {
  const SalePrefill({this.description, this.customer, this.amount});
  final String? description;
  final String? customer;
  final double? amount;

  factory SalePrefill.fromRepair(Repair r) => SalePrefill(
        description: '${r.code} ${r.deviceModel}${r.problem != null ? ' - ${r.problem}' : ''}',
        customer: r.customerName,
        amount: r.finalCharge ?? (r.estimatedCharge != null ? r.estimatedCharge! - r.advancePaid : null),
      );
}

Future<void> openSaleForm(BuildContext context, {SalePrefill? prefill}) =>
    showAppSheet(context, title: 'Nayi sale entry', builder: (_) => SaleFormWidget(prefill: prefill));

class SaleFormWidget extends HookConsumerWidget {
  const SaleFormWidget({super.key, this.prefill});
  final SalePrefill? prefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider);
    final stock = ref.watch(stockProvider).value ?? const <StockItem>[];
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final desc = useTextEditingController(text: prefill?.description ?? '');
    final amt = useTextEditingController(text: prefill?.amount == null ? '' : prefill!.amount!.round().toString());
    final exp = useTextEditingController();
    final cust = useTextEditingController(text: prefill?.customer ?? '');
    final staff = useTextEditingController(text: me?.name ?? '');
    final notes = useTextEditingController();
    final partQ = useTextEditingController();
    final pay = useState(payModes.first);
    final date = useState<String?>(today());
    final chosen = useState<List<(StockItem, int)>>([]);
    useListenable(partQ);

    final t = partQ.text.trim().toLowerCase();
    final matches = t.length < 2
        ? const <StockItem>[]
        : stock
            .where((i) => i.quantity > 0 && i.label.toLowerCase().contains(t) && !chosen.value.any((c) => c.$1.id == i.id))
            .take(12)
            .toList();

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final entry = <String, dynamic>{
        'entry_date': date.value ?? today(),
        'sale_description': desc.text.trim(),
        'customer_name': cust.text.trim(),
        'amount_received': toNum(amt.text),
        'expense': toNum(exp.text),
        'payment_mode': pay.value,
        'staff_name': staff.text.trim(),
        'notes': notes.text.trim(),
      };
      final nav = Navigator.of(context);
      final ok = await runAction(
        context,
        () => ref.read(repositoryProvider).createSale(entry, [for (final c in chosen.value) (c.$1.id, c.$2)]),
        ok: 'Sale save ho gayi: ${inr(entry['amount_received'])}',
      );
      if (ok) {
        nav.pop();
        await Future.wait([ref.read(salesProvider.notifier).refresh(), ref.read(stockProvider.notifier).refresh()]);
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Field(label: 'Kya kaam / kya becha', controller: desc, required: true, hint: 'Jaise: Vivo Y20 display change'),
          FieldRow([
            Field(label: 'Amount mila (₹)', controller: amt, decimal: true, required: true),
            Field(label: 'Kharcha (₹)', controller: exp, decimal: true, hint: '0'),
          ]),
          FieldRow([
            DropdownField<String>(label: 'Payment', value: pay.value, items: payModes, onChanged: (v) => pay.value = v),
            DateField(label: 'Date', value: date.value, onChanged: (v) => date.value = v),
          ]),
          FieldRow([
            Field(label: 'Customer', controller: cust),
            Field(label: 'Staff naam', controller: staff, required: true),
          ]),
          Field(
            label: 'Stock se part laga? (optional)',
            controller: partQ,
            hint: 'Part ka naam ya model likho',
            helper: 'Chune hue parts stock se apne aap kam ho jayenge.',
          ),
          if (t.length >= 2)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
              child: matches.isEmpty
                  ? const Padding(padding: EdgeInsets.all(14), child: Text('Stock me nahi mila', style: TextStyle(color: AppColors.muted)))
                  : Column(
                      children: [
                        for (final i in matches)
                          ListTile(
                            dense: true,
                            title: Text(i.label),
                            trailing: Text('${i.quantity} pcs', style: const TextStyle(color: AppColors.muted)),
                            onTap: () {
                              chosen.value = [...chosen.value, (i, 1)];
                              partQ.clear();
                            },
                          ),
                      ],
                    ),
            ),
          for (var idx = 0; idx < chosen.value.length; idx++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withValues(alpha: .3)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('${chosen.value[idx].$1.label}  (${chosen.value[idx].$1.quantity} pcs)')),
                  IconButton(
                    tooltip: 'Kam karo',
                    onPressed: chosen.value[idx].$2 <= 1
                        ? null
                        : () => chosen.value = [
                              for (var j = 0; j < chosen.value.length; j++)
                                j == idx ? (chosen.value[j].$1, chosen.value[j].$2 - 1) : chosen.value[j],
                            ],
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text('${chosen.value[idx].$2}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  IconButton(
                    tooltip: 'Badhao',
                    onPressed: chosen.value[idx].$2 >= chosen.value[idx].$1.quantity
                        ? null
                        : () => chosen.value = [
                              for (var j = 0; j < chosen.value.length; j++)
                                j == idx ? (chosen.value[j].$1, chosen.value[j].$2 + 1) : chosen.value[j],
                            ],
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'Hatao',
                    onPressed: () => chosen.value = [...chosen.value]..removeAt(idx),
                    icon: const Icon(Icons.close_rounded, color: AppColors.red),
                  ),
                ],
              ),
            ),
          Field(label: 'Notes', controller: notes),
          SheetActions(primary: BusyButton(label: 'Sale save karo', icon: Icons.check_rounded, onPressed: submit)),
        ],
      ),
    );
  }
}
