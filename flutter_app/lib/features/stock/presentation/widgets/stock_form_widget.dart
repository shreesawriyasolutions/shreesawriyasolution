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

Future<void> openStockForm(BuildContext context) => showAppSheet(context, title: 'Stock add', builder: (_) => const StockFormWidget());

StockItem? findSameStock(List<StockItem> stock, String p, String b, String m) {
  String n(String? x) => (x ?? '').trim().toLowerCase();
  for (final i in stock) {
    if (n(i.productName) == n(p) && n(i.brand) == n(b) && n(i.model) == n(m)) return i;
  }
  return null;
}

class StockFormWidget extends HookConsumerWidget {
  const StockFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockProvider).value ?? const <StockItem>[];
    final me = ref.watch(profileProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final product = useTextEditingController();
    final brand = useTextEditingController();
    final model = useTextEditingController();
    final qty = useTextEditingController();
    final buy = useTextEditingController();
    final sell = useTextEditingController();
    final supplier = useTextEditingController();
    final notes = useTextEditingController();
    final cat = useState(stockCategories.first);
    final date = useState<String?>(today());
    useListenable(Listenable.merge([product, brand, model]));

    final same = product.text.trim().isEmpty ? null : findSameStock(stock, product.text, brand.text, model.text);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final p = clean(product.text);
      final q = int.tryParse(qty.text);
      if (p == null || q == null || q < 0) {
        showToast(context, 'Product naam aur quantity daaliye.', error: true);
        return;
      }
      if (same != null && q == 0) {
        showToast(context, 'Yeh item pehle se hai. Quantity 1 ya zyada daaliye.', error: true);
        return;
      }
      final repo = ref.read(repositoryProvider);
      final nav = Navigator.of(context);
      final ok = await runAction(
        context,
        () => same != null
            ? repo.adjustStock(
                same.id,
                q,
                'Purchase',
                [clean(supplier.text), if (buy.text.trim().isNotEmpty) '₹${buy.text.trim()}/pc', clean(notes.text)].whereType<String>().join(' · ').let((s) => s.isEmpty ? null : s),
              )
            : repo.addStockItem({
                'product_name': p,
                'category': cat.value,
                'brand': clean(brand.text),
                'model': clean(model.text),
                'quantity': q,
                'purchase_price': numOrNull(buy.text),
                'selling_price': numOrNull(sell.text),
                'supplier': clean(supplier.text),
                'entry_date': date.value,
                'notes': clean(notes.text),
                'updated_by_name': me?.name,
              }),
        ok: same != null ? 'Quantity jod di' : 'Stock add ho gaya',
      );
      if (ok) {
        nav.pop();
        await ref.read(stockProvider.notifier).refresh();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Field(
            label: 'Product naam',
            controller: product,
            required: true,
            hint: 'Jaise: Display, Battery, Charger',
            helper: same != null ? 'Yeh item pehle se hai (${same.quantity} pcs). Quantity usi me jud jayegi.' : null,
          ),
          FieldRow([Field(label: 'Brand', controller: brand), Field(label: 'Model', controller: model)]),
          FieldRow([
            DropdownField<String>(label: 'Category', value: cat.value, items: stockCategories, onChanged: (v) => cat.value = v),
            Field(label: 'Quantity', controller: qty, digitsOnly: true, required: true),
          ]),
          FieldRow([Field(label: 'Kharid rate (₹)', controller: buy, decimal: true), Field(label: 'Bikri rate (₹)', controller: sell, decimal: true)]),
          FieldRow([
            Field(label: 'Supplier', controller: supplier),
            DateField(label: 'Date', value: date.value, onChanged: (v) => date.value = v),
          ]),
          Field(label: 'Notes', controller: notes),
          if (same != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Purana item: ${same.label}', style: const TextStyle(color: AppColors.gold)),
            ),
          SheetActions(primary: BusyButton(label: 'Save karo', icon: Icons.check_rounded, onPressed: submit)),
        ],
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
