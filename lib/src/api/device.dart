/// Platform detection, device info, and the global `vox` context.
///
/// ```dart
/// vox.isIOS              // true on iOS
/// vox.isAndroid          // true on Android
/// vox.isMobile           // Android || iOS
/// vox.isDesktop          // macOS || Windows || Linux
/// vox.isWeb              // true in browser
///
/// vox.device.name        // "iPhone 15 Pro"
/// vox.device.os          // "iOS 17.2"
///
/// vox.theme.primary      // active primary Color
/// vox.theme.toggle()     // switch dark ↔ light
/// ```
library;

export '../core/device/device_info.dart' show VoxDeviceInfo, vox;
