import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// User ko dikhane layak (Hinglish) error message ke saath exception.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Website wale errMsg() jaisa hi mapping.
String friendlyError(Object? e) {
  if (e is AppException) return e.message;
  if (e is TimeoutException) return 'Internet check karein, data save nahi hua.';
  String msg = '';
  String? code;
  if (e is PostgrestException) {
    msg = e.message;
    code = e.code;
  } else if (e is AuthException) {
    msg = e.message;
  } else if (e is StorageException) {
    msg = e.message;
  } else if (e != null) {
    msg = e.toString();
  }
  final m = msg.toLowerCase();
  if (m.contains('fetch') || m.contains('network') || m.contains('failed host lookup') || m.contains('connection') || m.contains('socketexception')) {
    return 'Internet check karein, data save nahi hua.';
  }
  if (m.contains('staff sirf status')) return 'Staff sirf status badal sakta hai. Baaki badlav Admin karega.';
  if (m.contains('itna stock nahi') || m.contains('item nahi mila') || m.contains('part ') || m.contains('change 0')) return msg;
  if (m.contains('invalid mobile')) return 'Mobile number 10 digit ka hona chahiye.';
  if (m.contains('imei')) return 'IMEI 14-16 digit ka hona chahiye.';
  if (code == '42501' || m.contains('row-level security') || m.contains('permission')) {
    return 'Aapke paas yeh karne ki permission nahi hai.';
  }
  if (m.contains('check constraint') || m.contains('violates')) return 'Kuch value galat hai, form check karein.';
  return 'Kuch gadbad hui. Dobara try karein.';
}
