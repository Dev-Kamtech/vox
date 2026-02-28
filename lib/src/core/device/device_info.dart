import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../theme/theme_engine.dart';

// ---------------------------------------------------------------------------
// VoxDeviceInfo
// ---------------------------------------------------------------------------

/// Hardware and OS information for the current device.
///
/// Access via `vox.device`. Optionally initialize early via [VoxDeviceInfo.init]:
///
/// ```dart
/// void main() => voxApp(
///   home: HomeScreen(),
///   init: VoxDeviceInfo.init,
/// );
///
/// // Then anywhere:
/// log.i(vox.device.name); // "iPhone 15 Pro"
/// log.i(vox.device.os);   // "iOS 17.2"
/// ```
class VoxDeviceInfo {
  VoxDeviceInfo._();

  static final VoxDeviceInfo _singleton = VoxDeviceInfo._();

  String _name = '';
  String _os = '';
  bool _initialized = false;

  /// Initialize device info. Safe to call multiple times — only runs once.
  static Future<void> init() => _singleton._doInit();

  Future<void> _doInit() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        _name = info.browserName.name;
        _os = 'Web';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final info = await plugin.androidInfo;
            _name = info.model;
            _os = 'Android ${info.version.release}';
          case TargetPlatform.iOS:
            final info = await plugin.iosInfo;
            _name = info.name;
            _os = '${info.systemName} ${info.systemVersion}';
          case TargetPlatform.macOS:
            final info = await plugin.macOsInfo;
            _name = info.computerName;
            _os = 'macOS ${info.osRelease}';
          case TargetPlatform.windows:
            final info = await plugin.windowsInfo;
            _name = info.computerName;
            _os = 'Windows ${info.displayVersion}';
          case TargetPlatform.linux:
            final info = await plugin.linuxInfo;
            _name = info.name;
            _os = '${info.name} ${info.version ?? ''}'.trim();
          case TargetPlatform.fuchsia:
            _name = 'Fuchsia';
            _os = 'Fuchsia';
        }
      }
    } catch (_) {
      // Device info is best-effort — never crash over it.
    }
  }

  /// Human-readable device name. Returns `"Unknown"` before [init] runs.
  String get name => _name.isNotEmpty ? _name : 'Unknown';

  /// OS name and version. Returns `"Unknown"` before [init] runs.
  String get os => _os.isNotEmpty ? _os : 'Unknown';
}

// ---------------------------------------------------------------------------
// _Vox — global context
// ---------------------------------------------------------------------------

/// The global `vox` context — platform detection, device info, and theme.
///
/// ```dart
/// vox.isIOS              // true on iOS
/// vox.isMobile           // true on Android or iOS
/// vox.device.name        // "Pixel 7"
/// vox.device.os          // "Android 14"
/// vox.theme.primary      // active primary color
/// vox.theme.toggle()     // switch dark ↔ light
/// ```
final class _Vox {
  const _Vox();

  // ── Platform flags ─────────────────────────────────────────────────────────

  /// True when running in a web browser.
  bool get isWeb => kIsWeb;

  /// True on Android (not web).
  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// True on iOS (not web).
  bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// True on macOS desktop (not web).
  bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// True on Windows desktop (not web).
  bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// True on Linux desktop (not web).
  bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// True on Android or iOS.
  bool get isMobile => isAndroid || isIOS;

  /// True on macOS, Windows, or Linux.
  bool get isDesktop => isMacOS || isWindows || isLinux;

  // ── Device ─────────────────────────────────────────────────────────────────

  /// Device name and OS version.
  VoxDeviceInfo get device => VoxDeviceInfo._singleton;

  // ── Theme ──────────────────────────────────────────────────────────────────

  /// Active theme controller — read tokens or switch modes at runtime.
  VoxThemeController get theme => VoxThemeController.instance;
}

/// Global vox context accessor.
///
/// Provides platform detection, device info, and theme access from anywhere
/// in the app — no [BuildContext] required.
///
/// ```dart
/// vox.isIOS
/// vox.device.name
/// vox.theme.primary
/// vox.theme.toggle()
/// ```
const vox = _Vox();
