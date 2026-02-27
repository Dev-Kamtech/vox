/// vox api: drawer — side navigation drawer.
///
/// ```dart
/// screen("Home", body,
///   drawer: drawer([
///     navItem("Home",     Icons.home,     onTap: () => go(HomeScreen())),
///     navItem("Profile",  Icons.person,   onTap: () => go(ProfileScreen())),
///     navItem("Settings", Icons.settings, onTap: () => go(SettingsScreen())),
///   ]),
/// )
///
/// // Open / close programmatically
/// openDrawer();
/// closeDrawer();
/// ```
library;

export '../core/drawer/drawer_engine.dart'
    show VoxDrawer, VoxNavItem, VoxDrawerController;

import 'package:flutter/material.dart';

import '../core/drawer/drawer_engine.dart';

/// Create a [VoxNavItem] for use inside [drawer].
///
/// [onTap] is called after the drawer closes automatically.
VoxNavItem navItem(
  String label,
  IconData icon, {
  VoidCallback? onTap,
  bool selected = false,
}) =>
    VoxNavItem(
      label: label,
      icon: icon,
      onTap: onTap,
      selected: selected,
    );

/// Create a [VoxDrawer] from a list of [VoxNavItem]s.
///
/// Pass [header] to customize the drawer header (defaults to an empty header).
VoxDrawer drawer(List<VoxNavItem> items, {Widget? header}) =>
    VoxDrawer(items, header: header);

/// Open the drawer on the current screen.
void openDrawer() => VoxDrawerController.open();

/// Close the drawer on the current screen.
void closeDrawer() => VoxDrawerController.close();
