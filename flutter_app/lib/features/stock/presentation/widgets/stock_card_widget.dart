import 'package:flutter/material.dart';

import '../../../../core/config.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/ui.dart';

class StockCardWidget extends StatelessWidget {
  const StockCardWidget({super.key, required this.item, required this.onTap, this.showBuy = false});
  final StockItem item;
  final VoidCallback onTap;
  final bool showBuy;

  @override
  Widget build(BuildContext context) {
    final it = item;
    final st = it.state;
    final qc = switch (st) {
      StockState.out => AppColors.red,
      StockState.low => AppColors.amber,
      StockState.ok => AppColors.fg,
    };
    final icon = switch (it.category) {
      'Accessory' => Icons.headphones_rounded,
      'Mobile' => Icons.smartphone_rounded,
      'Spare Part' => Icons.memory_rounded,
      _ => Icons.category_rounded,
    };
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      highlight: st == StockState.out ? AppColors.red.withValues(alpha: .4) : null,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.silver, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                Text(it.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 13.5)),
                const SizedBox(height: 4),
                Text(
                  [
                    it.category,
                    if (showBuy && it.purchasePrice != null) 'Kharid ${inr(it.purchasePrice)}',
                    if (it.sellingPrice != null) 'Bikri ${inr(it.sellingPrice)}',
                    if (it.minQuantity > 0) 'Min ${it.minQuantity}',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${it.quantity}', style: AppTheme.number(size: 26, color: qc)),
              if (st == StockState.ok)
                const Text('pcs', style: TextStyle(color: AppColors.muted, fontSize: 12))
              else
                Pill(st == StockState.out ? 'Khatam' : 'Kam', tone: st == StockState.out ? Tone.red : Tone.amber, dot: false),
            ],
          ),
        ],
      ),
    );
  }
}
