import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/core/theme/xf_theme_pack.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily, {this.premiumPreset});
  final AppThemeMode mode;
  final String fontFamily;
  final XfThemePreset? premiumPreset;

  ColorScheme _premiumScheme(Brightness brightness, ColorScheme? fallback) {
    final preset = premiumPreset;
    if (preset == null) {
      return fallback ??
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF14B8A6),
            brightness: brightness,
          );
    }
    final t = preset.tokens;
    return ColorScheme.fromSeed(
      seedColor: t.accentA,
      brightness: brightness,
    ).copyWith(
      primary: t.accentA,
      secondary: t.accentB,
      tertiary: t.accentC,
      surface: t.surfaceColor,
      onSurface: t.textColor,
      onSurfaceVariant: t.mutedColor,
    );
  }

  ThemeData lightTheme(ColorScheme? lightColorScheme) {
    final ColorScheme scheme = _premiumScheme(Brightness.light, lightColorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      extensions: const <ThemeExtension<dynamic>>{ConnectionButtonTheme.light},
    );
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    final ColorScheme scheme = _premiumScheme(Brightness.dark, darkColorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          mode.trueBlack ? Colors.black : (premiumPreset?.tokens.backgroundColor ?? scheme.surface),
      fontFamily: fontFamily,
      extensions: const <ThemeExtension<dynamic>>{ConnectionButtonTheme.light},
    );
  }

  CupertinoThemeData cupertinoThemeData(bool sysDark, ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
    final bool isDark = switch (mode) {
      AppThemeMode.system => sysDark,
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.black => true,
    };
    final def = CupertinoThemeData(brightness: isDark ? Brightness.dark : Brightness.light);
    // final def = CupertinoThemeData(brightness: Brightness.dark);

    // return def;
    final defaultMaterialTheme = isDark ? darkTheme(darkColorScheme) : lightTheme(lightColorScheme);
    return MaterialBasedCupertinoThemeData(
      materialTheme: defaultMaterialTheme.copyWith(
        cupertinoOverrideTheme: def.copyWith(
          textTheme: CupertinoTextThemeData(
            textStyle: def.textTheme.textStyle.copyWith(fontFamily: fontFamily),
            actionTextStyle: def.textTheme.actionTextStyle.copyWith(fontFamily: fontFamily),
            navActionTextStyle: def.textTheme.navActionTextStyle.copyWith(fontFamily: fontFamily),
            navTitleTextStyle: def.textTheme.navTitleTextStyle.copyWith(fontFamily: fontFamily),
            navLargeTitleTextStyle: def.textTheme.navLargeTitleTextStyle.copyWith(fontFamily: fontFamily),
            pickerTextStyle: def.textTheme.pickerTextStyle.copyWith(fontFamily: fontFamily),
            dateTimePickerTextStyle: def.textTheme.dateTimePickerTextStyle.copyWith(fontFamily: fontFamily),
            tabLabelTextStyle: def.textTheme.tabLabelTextStyle.copyWith(fontFamily: fontFamily),
          ).copyWith(),
          barBackgroundColor: def.barBackgroundColor,
          scaffoldBackgroundColor: def.scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
