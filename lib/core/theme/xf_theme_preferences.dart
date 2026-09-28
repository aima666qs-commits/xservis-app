import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/core/theme/xf_theme_pack.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _xfThemePresetKey = 'xf_theme_preset';
const xfThemeDefaultPresetId = 'particle-field';

class XfThemePresetController extends StateNotifier<String> {
  XfThemePresetController(this._prefs)
      : super(_prefs.getString(_xfThemePresetKey) ?? xfThemeDefaultPresetId);

  final SharedPreferences _prefs;

  Future<void> selectPreset(String id) async {
    final next = id.trim().isEmpty ? xfThemeDefaultPresetId : id.trim();
    if (state == next) return;
    state = next;
    await _prefs.setString(_xfThemePresetKey, next);
  }

  Future<void> reset() => selectPreset(xfThemeDefaultPresetId);
}

final xfThemePresetIdProvider =
    StateNotifierProvider<XfThemePresetController, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return XfThemePresetController(prefs);
});

final activeXfThemePresetProvider = Provider<XfThemePreset?>((ref) {
  final selected = ref.watch(xfThemePresetIdProvider);
  final pack = ref.watch(xfThemePackProvider).valueOrNull;
  if (pack == null || pack.isEmpty) return null;
  for (final preset in pack) {
    if (preset.id == selected) return preset;
  }
  return pack.first;
});
