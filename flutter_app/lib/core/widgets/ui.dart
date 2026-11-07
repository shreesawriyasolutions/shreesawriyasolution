import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Rangeen chhota label: status, role, bill type.
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.tone = Tone.muted, this.dot = true});
  final String label;
  final Tone tone;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: c.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(color: c, fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.1)),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = statusOf(status);
    return Pill(s.label, tone: s.tone);
  }
}

/// Dabne wala card (list items).
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.highlight, this.selected = false});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? highlight;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final edge = selected ? AppColors.gold : (highlight ?? AppColors.line);
    return Material(
      color: selected ? AppColors.gold.withValues(alpha: .08) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: BorderSide(color: edge, width: selected ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.gold.withValues(alpha: .10),
        highlightColor: AppColors.gold.withValues(alpha: .05),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Bada sona (gold) card: aaj ki sale / total.
class HeroKpi extends StatelessWidget {
  const HeroKpi({super.key, required this.label, required this.value, required this.sub, this.icon = Icons.trending_up_rounded, this.onTap});
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: .22), blurRadius: 28, offset: const Offset(0, 10))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -26,
                child: Opacity(opacity: .16, child: Image.asset('assets/images/emblem.png', height: 150, color: AppColors.goldInk, colorBlendMode: BlendMode.srcIn)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label.toUpperCase(),
                            style: const TextStyle(color: AppColors.goldInk, fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(color: AppColors.goldInk.withValues(alpha: .12), shape: BoxShape.circle),
                          child: Icon(icon, size: 18, color: AppColors.goldInk),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value, style: AppTheme.number(size: 40, color: AppColors.goldInk)),
                    ),
                    const SizedBox(height: 2),
                    Text(sub, style: TextStyle(color: AppColors.goldInk.withValues(alpha: .75), fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chhota KPI tile.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, required this.sub, this.icon, this.color, this.onTap, this.selected = false});
  final String label;
  final String value;
  final String sub;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.fg;
    return AppCard(
      onTap: onTap,
      selected: selected,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color ?? AppColors.muted),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTheme.number(size: 24, color: c)),
          ),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}

/// 2 column grid jo chhoti screen par bhi theek dikhe.
class TwoColGrid extends StatelessWidget {
  const TwoColGrid({super.key, required this.children, this.gap = 10, this.minTile = 160});
  final List<Widget> children;
  final double gap;
  final double minTile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = (c.maxWidth / (minTile + gap)).floor().clamp(1, 4);
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.head(size: 28)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(color: AppColors.muted, fontSize: 14.5)),
                ],
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 9),
          Expanded(child: Text(title, style: AppTheme.head(size: 18, weight: FontWeight.w700))),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Row(mainAxisSize: MainAxisSize.min, children: [Text(actionLabel!), const Icon(Icons.chevron_right_rounded, size: 18)])),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.message, this.icon = Icons.inbox_outlined});
  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.line),
        color: AppColors.surface.withValues(alpha: .5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.gold.withValues(alpha: .7)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
          if (message != null) ...[
            const SizedBox(height: 4),
            Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

class LoadingBlock extends StatelessWidget {
  const LoadingBlock({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Container(
            height: 86,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppTheme.radius)),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: AppColors.gold.withValues(alpha: .08)),
      ],
    );
  }
}

class ErrorBlock extends StatelessWidget {
  const ErrorBlock({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.red.withValues(alpha: .3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.red),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Dobara try karo')),
        ],
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.hint, required this.onChanged, this.controller});
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
        fillColor: AppColors.surface,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(99)), borderSide: BorderSide(color: AppColors.line)),
        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(99)), borderSide: BorderSide(color: AppColors.line)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(99)), borderSide: BorderSide(color: AppColors.gold)),
      ),
    );
  }
}

/// Filter chips ki horizontal line.
class ChipBar<T> extends StatelessWidget {
  const ChipBar({super.key, required this.items, required this.selected, required this.onSelect, required this.label, this.count});
  final List<T> items;
  final T selected;
  final ValueChanged<T> onSelect;
  final String Function(T) label;
  final int Function(T)? count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final it = items[i];
          final on = it == selected;
          return ChoiceChip(
            selected: on,
            showCheckmark: false,
            onSelected: (_) => onSelect(it),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label(it), style: TextStyle(color: on ? AppColors.gold : AppColors.fg, fontWeight: FontWeight.w600)),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: on ? AppColors.gold : AppColors.surface3,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('${count!(it)}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: on ? AppColors.goldInk : AppColors.muted)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Label: value rows (detail sheets).
class KvList extends StatelessWidget {
  const KvList(this.rows, {super.key});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(border: i == rows.length - 1 ? null : const Border(bottom: BorderSide(color: AppColors.line))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 108, child: Text(rows[i].$1, style: const TextStyle(color: AppColors.muted, fontSize: 14))),
                  Expanded(child: Text(rows[i].$2, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TimelineItem {
  const TimelineItem({required this.title, this.sub, this.color});
  final String title;
  final String? sub;
  final Color? color;
}

class Timeline extends StatelessWidget {
  const Timeline(this.items, {super.key});
  final List<TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('Koi history nahi', style: TextStyle(color: AppColors.muted));
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: items[i].color ?? AppColors.gold, shape: BoxShape.circle),
                      ),
                      if (i != items.length - 1) Expanded(child: Container(width: 2, color: AppColors.line)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (items[i].sub != null) Text(items[i].sub!, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class NoteBox extends StatelessWidget {
  const NoteBox(this.text, {super.key, this.icon = Icons.info_outline_rounded, this.color = AppColors.blue});
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5, height: 1.35))),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.text, {super.key, this.size = 44, this.gold = false});
  final String text;
  final double size;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gold ? AppColors.goldGradient : null,
        color: gold ? null : AppColors.surface3,
        border: gold ? null : Border.all(color: AppColors.line),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: size * .36, color: gold ? AppColors.goldInk : AppColors.gold)),
    );
  }
}

/// Entry animation for lists.
extension EntryAnim on Widget {
  Widget entry(int i) => animate().fadeIn(duration: 280.ms, delay: (40 * i.clamp(0, 8)).ms).slideY(begin: .06, end: 0, curve: Curves.easeOutCubic);
}
