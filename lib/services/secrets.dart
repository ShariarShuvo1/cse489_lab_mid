import 'package:flutter/services.dart';

// Took help from AI to implement secure secrets management
class Secrets {
  static const _dartDefineKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const MethodChannel _channel = MethodChannel('app/secrets');
  static String? _platformKey;

  static Future<void> loadFromPlatform() async {
    try {
      final k = await _channel.invokeMethod<String>('getGoogleMapsApiKey');
      if (k != null && k.isNotEmpty) _platformKey = k;
    } catch (_) {
      // ignore
    }
  }

  static String get googleMapsApiKey {
    if (_dartDefineKey.isNotEmpty) return _dartDefineKey;
    if (_platformKey != null && _platformKey!.isNotEmpty) return _platformKey!;
    return '';
  }
}
