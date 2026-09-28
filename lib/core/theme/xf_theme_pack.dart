import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const xfThemePackAsset = 'assets/themes/xf-theme-pack.v1.json';

Color xfColor(String value, {Color fallback = const Color(0xFF7C5CFF)}) {
  final normalized = value.trim().replaceFirst('#', '');
  if (normalized.length != 6) return fallback;
  final parsed = int.tryParse(normalized, radix: 16);
  return parsed == null ? fallback : Color(0xFF000000 | parsed);
}

class XfThemeTokens {
  const XfThemeTokens({
    required this.bg,
    required this.surface,
    required this.text,
    required this.muted,
    required this.a,
    required this.b,
    required this.c,
    required this.good,
  });

  final String bg;
  final String surface;
  final String text;
  final String muted;
  final String a;
  final String b;
  final String c;
  final String good;

  factory XfThemeTokens.fromJson(Map<String, dynamic> json) => XfThemeTokens(
        bg: json['bg']?.toString() ?? '#070712',
        surface: json['surface']?.toString() ?? '#15161f',
        text: json['text']?.toString() ?? '#f6f4ff',
        muted: json['muted']?.toString() ?? '#aaa4bd',
        a: json['a']?.toString() ?? '#7c5cff',
        b: json['b']?.toString() ?? '#00eaff',
        c: json['c']?.toString() ?? '#ff4fc3',
        good: json['good']?.toString() ?? '#4cff8f',
      );

  Color get backgroundColor => xfColor(bg, fallback: const Color(0xFF070712));
  Color get surfaceColor => xfColor(surface, fallback: const Color(0xFF15161F));
  Color get textColor => xfColor(text, fallback: Colors.white);
  Color get mutedColor => xfColor(muted, fallback: const Color(0xFFAAA4BD));
  Color get accentA => xfColor(a);
  Color get accentB => xfColor(b, fallback: const Color(0xFF00EAFF));
  Color get accentC => xfColor(c, fallback: const Color(0xFFFF4FC3));
  Color get successColor => xfColor(good, fallback: const Color(0xFF4CFF8F));
}

class XfThemePreset {
  const XfThemePreset({
    required this.id,
    required this.name,
    required this.family,
    required this.familyName,
    required this.background,
    required this.cardStyle,
    required this.transition,
    required this.interaction,
    required this.typography,
    required this.intensity,
    required this.tokens,
  });

  final String id;
  final String name;
  final String family;
  final String familyName;
  final String background;
  final String cardStyle;
  final String transition;
  final String interaction;
  final String typography;
  final String intensity;
  final XfThemeTokens tokens;

  factory XfThemePreset.fromJson(Map<String, dynamic> json) => XfThemePreset(
        id: json['id']?.toString() ?? 'particle-field',
        name: json['name']?.toString() ?? 'XFreedom Theme',
        family: json['family']?.toString() ?? 'immersive',
        familyName: json['familyName']?.toString() ?? 'Immersive Backgrounds',
        background: json['background']?.toString() ?? 'particle-field',
        cardStyle: json['cardStyle']?.toString() ?? 'glass',
        transition: json['transition']?.toString() ?? 'fade-up',
        interaction: json['interaction']?.toString() ?? 'lift',
        typography: json['typography']?.toString() ?? 'display',
        intensity: json['intensity']?.toString() ?? 'medium',
        tokens: XfThemeTokens.fromJson(
          (json['tokens'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
        ),
      );
}

final xfThemePackProvider = FutureProvider<List<XfThemePreset>>((ref) async {
  final raw = await rootBundle.loadString(xfThemePackAsset);
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid XFreedom theme pack root');
  }
  final items = decoded['presets'];
  if (items is! List || items.length < 50) {
    throw const FormatException('XFreedom theme pack must contain at least 50 presets');
  }
  final presets = items
      .whereType<Map>()
      .map((item) => XfThemePreset.fromJson(item.cast<String, dynamic>()))
      .toList(growable: false);
  if (presets.map((item) => item.id).toSet().length != presets.length) {
    throw const FormatException('XFreedom theme preset IDs must be unique');
  }
  return List.unmodifiable(presets);
});
