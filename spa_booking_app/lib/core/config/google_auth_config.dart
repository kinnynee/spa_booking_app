import 'package:flutter/foundation.dart';

/// OAuth client IDs are supplied at build time so no environment-specific
/// configuration is committed with the application source.
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '450931681155-6snb0nvf9quv1jqpgg4m0008tfg8qod2.apps.googleusercontent.com',
  );

  static bool get isSupportedOnCurrentPlatform {
    if (kIsWeb) {
      return true;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  static bool get isConfiguredForCurrentPlatform {
    if (kIsWeb) {
      return webClientId.isNotEmpty;
    }

    return switch (defaultTargetPlatform) {
      // Android uses the Web/server OAuth client configured in this app.
      TargetPlatform.android => true,
      TargetPlatform.iOS || TargetPlatform.macOS =>
        iosClientId.isNotEmpty && serverClientId.isNotEmpty,
      _ => false,
    };
  }

  static String? get clientId {
    if (kIsWeb) {
      return _emptyToNull(webClientId);
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => _emptyToNull(iosClientId),
      _ => null,
    };
  }

  static String? get backendClientId => _emptyToNull(serverClientId);

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
