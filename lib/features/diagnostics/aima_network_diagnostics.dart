import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Privacy-first network snapshot supplied by native Android/iOS APIs.
///
/// No identifiers, phone numbers, SIM details, cell IDs, IP addresses or
/// browsing data are collected. The channel only returns coarse connectivity
/// state required to explain why the tunnel is reconnecting.
class AimaNetworkSnapshot {
  const AimaNetworkSnapshot({
    required this.supported,
    required this.hasNetwork,
    required this.validated,
    required this.captivePortal,
    required this.transport,
    required this.radioGeneration,
    required this.expensive,
    required this.constrained,
    required this.networkChanged,
    required this.checkedAt,
  });

  const AimaNetworkSnapshot.unsupported()
      : supported = false,
        hasNetwork = false,
        validated = false,
        captivePortal = false,
        transport = 'unknown',
        radioGeneration = 'unknown',
        expensive = false,
        constrained = false,
        networkChanged = false,
        checkedAt = null;

  final bool supported;
  final bool hasNetwork;
  final bool validated;
  final bool captivePortal;
  final String transport;
  final String radioGeneration;
  final bool expensive;
  final bool constrained;
  final bool networkChanged;
  final DateTime? checkedAt;

  String get transportLabel => switch (transport) {
        'wifi' => 'Wi-Fi',
        'cellular' when radioGeneration != 'unknown' => radioGeneration,
        'cellular' => 'Мобильная сеть',
        'ethernet' => 'Ethernet',
        'vpn' => 'VPN',
        'none' => 'Нет сети',
        _ => 'Сеть не определена',
      };

  factory AimaNetworkSnapshot.fromMap(
    Map<Object?, Object?> map, {
    required bool networkChanged,
  }) {
    bool readBool(String key) => map[key] == true;
    String readString(String key) => (map[key] as String?)?.toLowerCase() ?? 'unknown';

    return AimaNetworkSnapshot(
      supported: true,
      hasNetwork: readBool('hasNetwork'),
      validated: readBool('validated'),
      captivePortal: readBool('captivePortal'),
      transport: readString('transport'),
      radioGeneration: (map['radioGeneration'] as String?) ?? 'unknown',
      expensive: readBool('expensive'),
      constrained: readBool('constrained'),
      networkChanged: networkChanged,
      checkedAt: DateTime.now(),
    );
  }
}

class AimaNetworkDiagnosticsService {
  static const MethodChannel _channel = MethodChannel('aima/network');

  String? _lastSignature;
  bool _firstRead = true;

  Future<AimaNetworkSnapshot> read() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return const AimaNetworkSnapshot.unsupported();
    }

    try {
      final raw = await _channel.invokeMapMethod<Object?, Object?>('getNetworkSnapshot');
      if (raw == null) return const AimaNetworkSnapshot.unsupported();

      final signature = [
        raw['hasNetwork'],
        raw['validated'],
        raw['transport'],
        raw['radioGeneration'],
      ].join('|');

      final changed = !_firstRead && _lastSignature != null && _lastSignature != signature;
      _firstRead = false;
      _lastSignature = signature;

      return AimaNetworkSnapshot.fromMap(raw, networkChanged: changed);
    } on MissingPluginException {
      return const AimaNetworkSnapshot.unsupported();
    } on PlatformException {
      return const AimaNetworkSnapshot.unsupported();
    }
  }

  Stream<AimaNetworkSnapshot> watch() async* {
    while (true) {
      yield await read();
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }
}

final aimaNetworkDiagnosticsServiceProvider = Provider<AimaNetworkDiagnosticsService>(
  (ref) => AimaNetworkDiagnosticsService(),
);

final aimaNetworkDiagnosticsProvider = StreamProvider.autoDispose<AimaNetworkSnapshot>(
  (ref) => ref.watch(aimaNetworkDiagnosticsServiceProvider).watch(),
);
