import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

String _cell(Object? v) {
  var s = v?.toString() ?? '';
  // Excel formula injection se bachao.
  if (RegExp(r'^[=+\-@]').hasMatch(s)) s = "'$s";
  return '"${s.replaceAll('"', '""')}"';
}

String buildCsv(List<String> head, List<List<Object?>> rows) =>
    '﻿${[head.map(_cell).join(','), ...rows.map((r) => r.map(_cell).join(','))].join('\r\n')}';

/// CSV file share sheet se bhejo (WhatsApp, Drive, Files...).
Future<void> shareCsv(String fileName, List<String> head, List<List<Object?>> rows) async {
  final bytes = Uint8List.fromList(utf8.encode(buildCsv(head, rows)));
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'text/csv', name: fileName)],
      fileNameOverrides: [fileName],
      subject: fileName,
    ),
  );
}
