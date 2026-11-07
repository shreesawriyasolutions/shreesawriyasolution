import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config.dart';
import '../../../../core/data/shop_repository.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/sheet.dart';
import '../../../../core/widgets/ui.dart';

Future<void> openSaleDetail(BuildContext context, Sale sale) =>
    showAppSheet(context, title: 'Sale entry', builder: (_) => SaleDetailWidget(sale: sale));

class SaleDetailWidget extends HookConsumerWidget {
  const SaleDetailWidget({super.key, required this.sale});
  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = sale;
    final admin = ref.watch(isAdminProvider);
    final repo = ref.watch(repositoryProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final desc = useTextEditingController(text: s.description);
    final amt = useTextEditingController(text: _n(s.amount));
    final exp = useTextEditingController(text: _n(s.expense));
    final cust = useTextEditingController(text: s.customerName ?? '');
    final staff = useTextEditingController(text: s.staffName);
    final notes = useTextEditingController(text: s.notes ?? '');
    final pay = useState(payModes.contains(s.paymentMode) ? s.paymentMode : 'Other');
    final date = useState<String?>(s.entryDate);
    final parts = useFuture(useMemoized(() => repo.saleParts(s.id)));

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final o = <String, dynamic>{
        'sale_description': desc.text.trim(),
        'amount_received': toNum(amt.text),
        'expense': toNum(exp.text),
        'payment_mode': pay.value,
        'entry_date': date.value,
        'customer_name': clean(cust.text),
        'staff_name': staff.text.trim(),
        'notes': clean(notes.text),
      };
      final nav = Navigator.of(context);
      final ok = await runAction(context, () => repo.updateSale(s.id, o), ok: 'Sale update ho gayi');
      if (ok) {
        nav.pop();
        await ref.read(salesProvider.notifier).refresh();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(inr(s.amount), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.gold)),
              const Spacer(),
              Pill(s.paymentMode, tone: Tone.blue),
            ],
          ),
          Text('Profit ${inr(s.profit ?? (s.amount - s.expense))} · ${fmtDate(s.entryDate)}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          Field(label: 'Kaam / item', controller: desc, readOnly: !admin, required: true),
          FieldRow([
            Field(label: 'Amount (₹)', controller: amt, decimal: true, readOnly: !admin),
            Field(label: 'Kharcha (₹)', controller: exp, decimal: true, readOnly: !admin),
          ]),
          FieldRow([
            DropdownField<String>(label: 'Payment', value: pay.value, items: payModes, enabled: admin, onChanged: (v) => pay.value = v),
            DateField(label: 'Date', value: date.value, enabled: admin, onChanged: (v) => date.value = v),
          ]),
          FieldRow([
            Field(label: 'Customer', controller: cust, readOnly: !admin),
            Field(label: 'Staff', controller: staff, readOnly: !admin),
          ]),
          Field(label: 'Notes', controller: notes, readOnly: !admin),
          const Text('Stock se lage parts', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            parts.connectionState != ConnectionState.done
                ? 'Load ho raha hai…'
                : (parts.data == null || parts.data!.isEmpty)
                    ? 'Koi part nahi'
                    : parts.data!.join(', '),
          ),
          const SizedBox(height: 18),
          if (admin) ...[
            SheetActions(primary: BusyButton(label: 'Save karein', icon: Icons.check_rounded, onPressed: save)),
            const SizedBox(height: 12),
            ConfirmDeleteButton(
              what: 'Yeh sale entry (lage parts stock me wapas jayenge)',
              onConfirm: () async {
                final nav = Navigator.of(context);
                final ok = await runAction(context, () => repo.delete(DeleteKind.sale, s.id), ok: 'Delete ho gaya');
                if (ok) {
                  nav.pop();
                  await Future.wait([ref.read(salesProvider.notifier).refresh(), ref.read(stockProvider.notifier).refresh()]);
                }
              },
            ),
          ] else
            const NoteBox('Staff mode: entry badalne ya delete karne ke liye Admin se kahein.'),
        ],
      ),
    );
  }

  static String _n(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
}
