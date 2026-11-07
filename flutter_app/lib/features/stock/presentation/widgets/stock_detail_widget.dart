import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

Future<void> openStockDetail(BuildContext context, StockItem item) =>
    showAppSheet(context, title: item.label, builder: (_) => StockDetailWidget(id: item.id));

class StockDetailWidget extends HookConsumerWidget {
  const StockDetailWidget({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final it = ref.watch(stockProvider).value?.where((x) => x.id == id).firstOrNull;
    final admin = ref.watch(isAdminProvider);
    final me = ref.watch(profileProvider);
    final repo = ref.watch(repositoryProvider);
    final n = useTextEditingController(text: '1');
    final note = useTextEditingController();
    final reason = useState('Purchase');
    final history = useFuture(useMemoized(() => admin ? repo.stockHistory(id) : Future.value(<StockMovement>[]), [it?.quantity]));

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final product = useTextEditingController(text: it?.productName ?? '');
    final brand = useTextEditingController(text: it?.brand ?? '');
    final model = useTextEditingController(text: it?.model ?? '');
    final min = useTextEditingController(text: '${it?.minQuantity ?? 0}');
    final buy = useTextEditingController(text: it?.purchasePrice?.toString() ?? '');
    final sell = useTextEditingController(text: it?.sellingPrice?.toString() ?? '');
    final supplier = useTextEditingController(text: it?.supplier ?? '');
    final notes = useTextEditingController(text: it?.notes ?? '');
    final cat = useState(stockCategories.contains(it?.category) ? it!.category : 'Other');

    if (it == null) return const EmptyState(title: 'Item nahi mila', message: 'Shayad delete ho gaya.');

    final st = it.state;
    final tone = switch (st) { StockState.out => Tone.red, StockState.low => Tone.amber, StockState.ok => Tone.green };

    Future<void> adjust(int sign) async {
      final q = int.tryParse(n.text);
      if (q == null || q < 1) {
        showToast(context, 'Kitne pcs, yeh daaliye.', error: true);
        return;
      }
      var r = sign > 0 && !admin ? 'Purchase' : reason.value;
      if (sign < 0 && r == 'Purchase') r = 'Adjust';
      final ok = await runAction(context, () => repo.adjustStock(it.id, sign * q, r, clean(note.text)), ok: sign > 0 ? '$q pcs jode' : '$q pcs ghataye');
      if (ok) {
        note.clear();
        await ref.read(stockProvider.notifier).refresh();
      }
    }

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final ok = await runAction(
        context,
        () => repo.updateStock(it.id, {
          'product_name': product.text.trim(),
          'brand': clean(brand.text),
          'model': clean(model.text),
          'category': cat.value,
          'min_quantity': int.tryParse(min.text) ?? 0,
          'purchase_price': numOrNull(buy.text),
          'selling_price': numOrNull(sell.text),
          'supplier': clean(supplier.text),
          'notes': clean(notes.text),
          'updated_by_name': me?.name,
        }),
        ok: 'Item update ho gaya',
      );
      if (ok) await ref.read(stockProvider.notifier).refresh();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${it.quantity}', style: AppTheme.number(size: 44, color: AppColors.tone(tone))),
            const SizedBox(width: 6),
            const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('pcs', style: TextStyle(color: AppColors.muted, fontSize: 16))),
            const Spacer(),
            Pill(st == StockState.ok ? 'Stock theek' : st == StockState.low ? 'Kam stock' : 'Khatam', tone: tone),
          ],
        ),
        const SectionHeader('Quantity badlo'),
        FieldRow([
          Field(label: 'Kitne pcs', controller: n, digitsOnly: true),
          DropdownField<String>(
            label: 'Wajah',
            value: reason.value,
            items: admin ? stockReasons : const ['Purchase'],
            onChanged: (v) => reason.value = v,
          ),
        ]),
        Field(label: 'Note', controller: note, hint: 'Jaise: SSS-0123 me laga'),
        Row(
          children: [
            Expanded(child: BusyButton(label: 'Jodo', icon: Icons.add_rounded, onPressed: () => adjust(1))),
            if (admin) ...[
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(onPressed: () => adjust(-1), icon: const Icon(Icons.remove_rounded), label: const Text('Ghatao')),
              ),
            ],
          ],
        ),
        if (admin) ...[
          const SectionHeader('Details'),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Field(label: 'Product', controller: product, required: true),
                FieldRow([Field(label: 'Brand', controller: brand), Field(label: 'Model', controller: model)]),
                FieldRow([
                  DropdownField<String>(label: 'Category', value: cat.value, items: stockCategories, onChanged: (v) => cat.value = v),
                  Field(label: 'Min quantity (alert)', controller: min, digitsOnly: true),
                ]),
                FieldRow([Field(label: 'Kharid rate', controller: buy, decimal: true), Field(label: 'Bikri rate', controller: sell, decimal: true)]),
                Field(label: 'Supplier', controller: supplier),
                Field(label: 'Notes', controller: notes),
                BusyButton(label: 'Save karein', icon: Icons.check_rounded, onPressed: save),
              ],
            ),
          ),
          const SectionHeader('History'),
          if (history.connectionState != ConnectionState.done)
            const LinearProgressIndicator(minHeight: 2)
          else
            Timeline([
              for (final h in history.data ?? const <StockMovement>[])
                TimelineItem(
                  title: '${h.change > 0 ? '+' : ''}${h.change} → ${h.qtyAfter} pcs · ${h.reason == 'Opening' ? 'Shuruaati stock' : (h.reason ?? '')}'
                      '${h.note != null ? ' · ${h.note}' : ''}',
                  sub: '${fmtTime(h.at)}${h.by != null ? ' · ${h.by}' : ''}',
                  color: h.change > 0 ? AppColors.green : AppColors.red,
                ),
            ]),
          const SizedBox(height: 16),
          ConfirmDeleteButton(
            what: 'Yeh stock item (history ke saath)',
            onConfirm: () async {
              final nav = Navigator.of(context);
              final ok = await runAction(context, () => repo.delete(DeleteKind.stock, it.id), ok: 'Delete ho gaya');
              if (ok) {
                nav.pop();
                await ref.read(stockProvider.notifier).refresh();
              }
            },
          ),
        ] else ...[
          const SizedBox(height: 14),
          const NoteBox('Staff mode: naya maal jod sakte hain, kam sirf Admin karega.'),
        ],
      ],
    );
  }
}
