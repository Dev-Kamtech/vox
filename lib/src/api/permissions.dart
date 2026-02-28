/// vox api: permissions — runtime permission requests.
///
/// ```dart
/// // Request a permission
/// final granted = await ask(VoxPermission.camera);
/// if (granted) { /* start camera */ }
///
/// // Check without requesting
/// final hasLocation = await check(VoxPermission.location);
///
/// // Send user to settings if permanently denied
/// await openPermissionSettings();
/// ```
library;

export '../core/permissions/permissions.dart'
    show VoxPermissions, VoxPermission;

import '../core/permissions/permissions.dart';

/// Request [permission] from the user.
///
/// Returns `true` if granted, `false` if denied or permanently denied.
Future<bool> ask(VoxPermission permission) => VoxPermissions.ask(permission);

/// Check the current status of [permission] without requesting it.
///
/// Returns `true` if already granted.
Future<bool> check(VoxPermission permission) =>
    VoxPermissions.check(permission);

/// Open the device app settings page so the user can grant a denied permission.
Future<bool> openPermissionSettings() => VoxPermissions.openSettings();
