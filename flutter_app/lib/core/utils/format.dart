import 'package:intl/intl.dart';

final _inr = NumberFormat.decimalPattern('en_IN');

double toNum(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim()) ?? 0;
}

num? numOrNull(String v) {
  final t = v.trim();
  if (t.isEmpty) return null;
  return num.tryParse(t);
}

String? clean(String? v) {
  final t = (v ?? '').trim();
  return t.isEmpty ? null : t;
}

/// ₹12,500
String inr(Object? n) => '₹${_inr.format(toNum(n).round())}';

String pad2(int n) => n.toString().padLeft(2, '0');

/// yyyy-MM-dd (Supabase date columns).
String dstr(DateTime d) => '${d.year}-${pad2(d.month)}-${pad2(d.day)}';

String today() => dstr(DateTime.now());

DateTime? parseDay(String? s) {
  if (s == null || s.length < 10) return null;
  return DateTime.tryParse(s.substring(0, 10));
}

/// 7 Nov 2026
String fmtDate(String? s) {
  final d = parseDay(s);
  return d == null ? '' : DateFormat('d MMM y').format(d);
}

/// 7 Nov, 8:21 PM
String fmtTime(String? s) {
  if (s == null || s.isEmpty) return '';
  final d = DateTime.tryParse(s);
  return d == null ? '' : DateFormat('d MMM, h:mm a').format(d.toLocal());
}

String weekdayShort(DateTime d) => DateFormat('EEE').format(d);

String longToday() => DateFormat('EEEE, d MMMM').format(DateTime.now());

String initials(String? n) {
  final parts = (n ?? '?').trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
  final s = parts.map((w) => w[0]).join().toUpperCase();
  return s.isEmpty ? '?' : s;
}

String shortName(String? n) {
  final s = n ?? '';
  return s.contains('@') ? s.split('@').first : s;
}

double sumOf<T>(Iterable<T> list, Object? Function(T) f) => list.fold(0.0, (t, x) => t + toNum(f(x)));

String digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');
