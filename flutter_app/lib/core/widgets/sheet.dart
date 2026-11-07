import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Neeche se khulne wali sheet (form / details). Keyboard ke saath upar khisakti hai.
Future<T?> showAppSheet<T>(BuildContext context, {required String title, required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    constraints: const BoxConstraints(maxWidth: 720),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 6),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: AppTheme.head(size: 21), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    tooltip: 'Band karo',
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Builder(builder: builder),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Form field with label, consistent spacing.
class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.keyboard,
    this.maxLength,
    this.digitsOnly = false,
    this.decimal = false,
    this.required = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.obscure = false,
    this.autofill,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final TextInputType? keyboard;
  final int? maxLength;
  final bool digitsOnly;
  final bool decimal;
  final bool required;
  final bool readOnly;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final Iterable<String>? autofill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscure,
        maxLines: maxLines,
        minLines: 1,
        autofillHints: autofill,
        keyboardType: keyboard ?? (digitsOnly ? TextInputType.number : decimal ? const TextInputType.numberWithOptions(decimal: true) : null),
        inputFormatters: [
          if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
          if (decimal) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChanged,
        validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? 'Yeh bharna zaroori hai' : null : null),
        decoration: InputDecoration(labelText: required ? '$label *' : label, hintText: hint, helperText: helper, helperMaxLines: 2),
      ),
    );
  }
}

/// Do fields ek line me (chaudi screen par), warna ek ke neeche ek.
class FieldRow extends StatelessWidget {
  const FieldRow(this.children, {super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 360) return Column(children: children);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: children[i]),
          ],
        ],
      );
    });
  }
}

class DropdownField<T> extends StatelessWidget {
  const DropdownField({super.key, required this.label, required this.value, required this.items, required this.onChanged, this.itemLabel, this.enabled = true});
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? itemLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        decoration: InputDecoration(labelText: label),
        items: [for (final it in items) DropdownMenuItem<T>(value: it, child: Text(itemLabel?.call(it) ?? '$it'))],
        onChanged: enabled
            ? (v) {
                if (v != null) onChanged(v);
              }
            : null,
      ),
    );
  }
}

/// Date chunne wala field (yyyy-MM-dd string).
class DateField extends StatelessWidget {
  const DateField({super.key, required this.label, required this.value, required this.onChanged, this.allowClear = false, this.enabled = true});
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final d = value == null || value!.isEmpty ? null : DateTime.tryParse(value!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: !enabled
            ? null
            : () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: d ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  onChanged('${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                }
              },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: allowClear && d != null && enabled
                ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => onChanged(null))
                : const Icon(Icons.calendar_month_rounded, color: AppColors.muted, size: 20),
          ),
          child: Text(
            d == null ? 'Chuniye' : '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}',
            style: TextStyle(color: d == null ? AppColors.muted : AppColors.fg, fontSize: 15.5),
          ),
        ),
      ),
    );
  }
}

/// Multi-select chips (saath me aaya, phone ki halat).
class CheckChips extends StatelessWidget {
  const CheckChips({super.key, required this.label, required this.options, required this.selected, required this.onChanged});
  final String label;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                FilterChip(
                  label: Text(o),
                  selected: selected.contains(o),
                  onSelected: (v) => onChanged(v ? ({...selected, o}) : (selected.where((x) => x != o).toSet())),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Delete button jo pehle "pakka?" poochta hai.
class ConfirmDeleteButton extends StatefulWidget {
  const ConfirmDeleteButton({super.key, required this.what, required this.onConfirm, this.label = 'Delete'});
  final String what;
  final String label;
  final Future<void> Function() onConfirm;

  @override
  State<ConfirmDeleteButton> createState() => _ConfirmDeleteButtonState();
}

class _ConfirmDeleteButtonState extends State<ConfirmDeleteButton> {
  bool _ask = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    if (!_ask) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: BorderSide(color: AppColors.red.withValues(alpha: .4))),
        onPressed: () => setState(() => _ask = true),
        icon: const Icon(Icons.delete_outline_rounded),
        label: Text(widget.label),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${widget.what} pakka delete karein? Wapas nahi aayega.', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: _busy ? null : () => setState(() => _ask = false), child: const Text('Nahi'))),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          await widget.onConfirm();
                          if (mounted) setState(() => _busy = false);
                        },
                  child: const Text('Haan, delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gold submit button jo kaam chalte waqt spinner dikhata hai.
class BusyButton extends StatefulWidget {
  const BusyButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final IconData? icon;
  final Future<void> Function()? onPressed;

  @override
  State<BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<BusyButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _busy || widget.onPressed == null
          ? null
          : () async {
              setState(() => _busy = true);
              try {
                await widget.onPressed!();
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
      child: _busy
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.goldInk))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[Icon(widget.icon, size: 20), const SizedBox(width: 8)],
                Text(widget.label),
              ],
            ),
    );
  }
}

/// Neeche wali buttons ki line.
class SheetActions extends StatelessWidget {
  const SheetActions({super.key, required this.primary, this.secondary});
  final Widget primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(child: secondary ?? OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: primary),
        ],
      ),
    );
  }
}
