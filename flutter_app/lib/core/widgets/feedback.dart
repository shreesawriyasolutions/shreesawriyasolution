import 'dart:async';

import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../theme/app_colors.dart';

/// Upar dikhne wala chhota message. Root overlay me lagta hai taaki
/// bottom sheet ke upar bhi dikhe.
void showToast(BuildContext context, String message, {bool error = false}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Toast(message: message, error: error, onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.error, required this.onDone});
  final String message;
  final bool error;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..forward();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 3200), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.error ? AppColors.red : AppColors.gold;
    return Positioned(
      left: 16,
      right: 16,
      top: MediaQuery.paddingOf(context).top + 12,
      child: FadeTransition(
        opacity: _c,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -.4), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: .45)),
                  boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.error ? Icons.error_outline_rounded : Icons.check_circle_rounded, color: color, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(widget.message, style: const TextStyle(color: AppColors.fg, fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kaam chalao, galti par Hinglish toast dikhao. Success par [ok] message.
/// Return: true agar kaam ho gaya.
Future<bool> runAction(BuildContext context, Future<void> Function() fn, {String? ok}) async {
  try {
    await fn();
    if (ok != null && context.mounted) showToast(context, ok);
    return true;
  } catch (e) {
    debugPrint('Action failed: $e');
    if (context.mounted) showToast(context, friendlyError(e), error: true);
    return false;
  }
}
