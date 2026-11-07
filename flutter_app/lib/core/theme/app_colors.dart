import 'package:flutter/material.dart';

import '../config.dart';

/// Shree Sawriya brand palette: black, gold, silver + status colours.
class AppColors {
  AppColors._();

  static const bg = Color(0xFF0A0B0A);
  static const surface = Color(0xFF141614);
  static const surface2 = Color(0xFF1C1F1C);
  static const surface3 = Color(0xFF242824);
  static const line = Color(0xFF2A2E2A);
  static const fg = Color(0xFFF3EFE6);
  static const muted = Color(0xFF9C9D95);
  static const silver = Color(0xFFC9CCD0);

  static const gold = Color(0xFFC9A24A);
  static const goldLight = Color(0xFFEBCB7F);
  static const goldDeep = Color(0xFF8C6B22);
  static const goldInk = Color(0xFF16130A);

  static const brandGreen = Color(0xFF0A5A48);
  static const green = Color(0xFF3FB393);
  static const amber = Color(0xFFE6AD44);
  static const blue = Color(0xFF86AEE0);
  static const red = Color(0xFFE8776A);
  static const violet = Color(0xFFB69AE6);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
    stops: [0, .55, 1],
  );

  static const glowGradient = RadialGradient(
    center: Alignment(0, -1.1),
    radius: 1.2,
    colors: [Color(0x40C9A24A), Color(0x00C9A24A)],
  );

  static Color tone(Tone t) => switch (t) {
        Tone.blue => blue,
        Tone.violet => violet,
        Tone.amber => amber,
        Tone.gold => gold,
        Tone.green => green,
        Tone.red => red,
        Tone.muted => muted,
      };
}
