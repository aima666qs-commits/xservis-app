import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'analytics_controller.g.dart';

const String enableAnalyticsPrefKey = 'enable_analytics';

/// AIMA privacy policy: product analytics and remote crash reporting are
/// disabled. Diagnostics remain local on the device and can be exported by the
/// user manually from the logs screen.
@Riverpod(keepAlive: true)
class AnalyticsController extends _$AnalyticsController {
  @override
  Future<bool> build() async {
    if (_preferences.getBool(enableAnalyticsPrefKey) != false) {
      await _preferences.setBool(enableAnalyticsPrefKey, false);
    }
    return false;
  }

  SharedPreferences get _preferences =>
      ref.read(sharedPreferencesProvider).requireValue;

  Future<void> enableAnalytics() async {
    // Intentionally disabled in AIMA builds. Do not initialize a remote SDK.
    await _preferences.setBool(enableAnalyticsPrefKey, false);
    state = const AsyncData(false);
  }

  Future<void> disableAnalytics() async {
    await _preferences.setBool(enableAnalyticsPrefKey, false);
    state = const AsyncData(false);
  }
}
