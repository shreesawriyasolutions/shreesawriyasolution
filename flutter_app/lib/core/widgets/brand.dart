import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Apple-S emblem (logo ka icon wala hissa).
class BrandEmblem extends StatelessWidget {
  const BrandEmblem({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Shree Sawriya Solutions',
        child: Image.asset('assets/images/emblem.png', height: size, filterQuality: FilterQuality.medium),
      );
}

/// Pura logo (login screen par).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 220});
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Shree Sawriya Solution logo',
        child: Image.asset('assets/images/logo.png', width: width, filterQuality: FilterQuality.medium),
      );
}

/// "SHREE SAWRIYA" (silver + gold) wordmark.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 15.5 : 22.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(text: 'SHREE ', style: AppTheme.head(size: size, color: AppColors.silver, weight: FontWeight.w800)),
            TextSpan(text: 'SAWRIYA', style: AppTheme.head(size: size, color: AppColors.gold, weight: FontWeight.w800)),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text('SHOP APP', style: TextStyle(color: AppColors.muted, fontSize: compact ? 10 : 12, letterSpacing: 2.4, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class ModeBadge extends StatelessWidget {
  const ModeBadge({super.key, required this.admin});
  final bool admin;

  @override
  Widget build(BuildContext context) {
    final c = admin ? AppColors.gold : AppColors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: c.withValues(alpha: .5)),
        color: c.withValues(alpha: .1),
      ),
      child: Text(admin ? 'ADMIN' : 'STAFF', style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
    );
  }
}

class Avatar2 extends StatelessWidget {
  const Avatar2({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
      child: Text(initials(name), style: const TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}
