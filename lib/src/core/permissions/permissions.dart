/// vox core: permissions — runtime permission requests via permission_handler.
library;

import 'package:permission_handler/permission_handler.dart';

// ---------------------------------------------------------------------------
// VoxPermission — friendly enum wrapping permission_handler's Permission
// ---------------------------------------------------------------------------

/// Vox-friendly permission identifier.
///
/// Pass to [VoxPermissions.ask] or [VoxPermissions.check].
enum VoxPermission {
  camera,
  microphone,
  location,
  locationAlways,
  locationWhenInUse,
  storage,
  photos,
  contacts,
  notification,
}

// ---------------------------------------------------------------------------
// VoxPermissions — static facade
// ---------------------------------------------------------------------------

/// Request and check runtime permissions without BuildContext.
///
/// ```dart
/// final granted = await VoxPermissions.ask(VoxPermission.camera);
/// if (granted) { /* use camera */ }
///
/// final hasLocation = await VoxPermissions.check(VoxPermission.location);
/// ```
abstract final class VoxPermissions {
  static Permission _map(VoxPermission p) {
    return switch (p) {
      VoxPermission.camera => Permission.camera,
      VoxPermission.microphone => Permission.microphone,
      VoxPermission.location => Permission.location,
      VoxPermission.locationAlways => Permission.locationAlways,
      VoxPermission.locationWhenInUse => Permission.locationWhenInUse,
      VoxPermission.storage => Permission.storage,
      VoxPermission.photos => Permission.photos,
      VoxPermission.contacts => Permission.contacts,
      VoxPermission.notification => Permission.notification,
    };
  }

  /// Request [permission] from the user.
  ///
  /// Returns `true` if granted, `false` if denied or permanently denied.
  static Future<bool> ask(VoxPermission permission) async {
    final status = await _map(permission).request();
    return status.isGranted;
  }

  /// Check the current status of [permission] without requesting it.
  ///
  /// Returns `true` if already granted.
  static Future<bool> check(VoxPermission permission) async {
    final status = await _map(permission).status;
    return status.isGranted;
  }

  /// Open the device app settings page.
  ///
  /// Use when the user has permanently denied a permission and must
  /// enable it manually.
  static Future<bool> openSettings() => openAppSettings();
}
