import 'package:flutter/material.dart';

import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/ui.dart';

class RepairCardWidget extends StatelessWidget {
  const RepairCardWidget({super.key, required this.repair, required this.onTap});
  final Repair repair;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = repair;
    final meta = <(IconData, String)>[
      (Icons.event_outlined, fmtDate(r.receivedDate)),
      if (r.customerMobile != null) (Icons.call_outlined, r.customerMobile!),
      if (r.estimatedCharge != null) (Icons.currency_rupee_rounded, 'Est. ${inr(r.estimatedCharge)}'),
      if (r.estimatedDelivery != null && r.isOpen) (Icons.schedule_rounded, 'Dena: ${fmtDate(r.estimatedDelivery)}'),
    ];
    return AppCard(
      onTap: onTap,
      highlight: r.status == 'Ready for Pickup' ? AppColors.green.withValues(alpha: .45) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                child: const Icon(Icons.smartphone_rounded, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.code, style: const TextStyle(color: AppColors.gold, fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: .6)),
                    Text(r.customerName ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.head(size: 17, weight: FontWeight.w700)),
                    Text(
                      [r.deviceModel, if (r.problem != null) r.problem!].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(r.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final m in meta)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(m.$1, size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(m.$2, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
