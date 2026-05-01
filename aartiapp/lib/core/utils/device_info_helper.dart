import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Lightweight device metadata used by outbound sync payloads.
class DeviceSnapshot {
  /// Creates an immutable snapshot of the current device context.
  const DeviceSnapshot({
    required this.model,
    required this.osVersion,
    required this.platform,
  });

  /// Human-readable device model when available.
  final String model;

  /// Operating system version when available.
  final String osVersion;

  /// Normalized platform label.
  final String platform;
}

/// Builds normalized device metadata across Flutter platforms.
abstract final class DeviceInfoHelper {
  /// Returns the best available device snapshot for the current platform.
  static Future<DeviceSnapshot> getDeviceSnapshot() async {
    final plugin = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        return DeviceSnapshot(
          model: '${info.browserName.name} on ${info.platform ?? 'web'}',
          osVersion: info.userAgent ?? 'unknown',
          platform: 'web',
        );
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await plugin.androidInfo;
          return DeviceSnapshot(
            model: '${info.manufacturer} ${info.model}'.trim(),
            osVersion: 'Android ${info.version.release}',
            platform: 'android',
          );
        case TargetPlatform.iOS:
          final info = await plugin.iosInfo;
          return DeviceSnapshot(
            model: info.utsname.machine,
            osVersion: 'iOS ${info.systemVersion}',
            platform: 'ios',
          );
        case TargetPlatform.macOS:
          final info = await plugin.macOsInfo;
          return DeviceSnapshot(
            model: info.model,
            osVersion:
                '${info.majorVersion}.${info.minorVersion}.${info.patchVersion}',
            platform: 'macos',
          );
        case TargetPlatform.windows:
          final info = await plugin.windowsInfo;
          return DeviceSnapshot(
            model: info.computerName,
            osVersion:
                '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
            platform: 'windows',
          );
        case TargetPlatform.linux:
          final info = await plugin.linuxInfo;
          return DeviceSnapshot(
            model: info.prettyName,
            osVersion: info.version ?? 'unknown',
            platform: 'linux',
          );
        case TargetPlatform.fuchsia:
          return const DeviceSnapshot(
            model: 'Fuchsia device',
            osVersion: 'unknown',
            platform: 'fuchsia',
          );
      }
    } catch (_) {
      return const DeviceSnapshot(
        model: 'unknown',
        osVersion: 'unknown',
        platform: 'unknown',
      );
    }
  }
}
