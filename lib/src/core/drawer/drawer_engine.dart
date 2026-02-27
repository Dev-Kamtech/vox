/// vox core: drawer engine — side navigation drawer.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// VoxDrawerController — programmatic open / close
// ---------------------------------------------------------------------------

/// Controls the global scaffold drawer.
///
/// [screenLayout] registers its scaffold key here when a drawer is present.
/// Use [openDrawer] / [closeDrawer] from anywhere — no BuildContext required.
abstract final class VoxDrawerController {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  /// Open the drawer on the current screen.
  static void open() => scaffoldKey.currentState?.openDrawer();

  /// Close the drawer on the current screen.
  static void close() => scaffoldKey.currentState?.closeDrawer();
}

// ---------------------------------------------------------------------------
// VoxNavItem — a single drawer nav entry
// ---------------------------------------------------------------------------

/// A navigation item for use inside a drawer.
///
/// Created via `navItem()` in `api/drawer.dart`.
class VoxNavItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;

  const VoxNavItem({
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  /// Return a copy with [selected] set.
  VoxNavItem select(bool value) =>
      VoxNavItem(label: label, icon: icon, onTap: onTap, selected: value);
}

// ---------------------------------------------------------------------------
// VoxDrawer — the drawer widget
// ---------------------------------------------------------------------------

/// A side navigation drawer. Created by `drawer([])` in `api/drawer.dart`.
///
/// ```dart
/// screen("Home", body,
///   drawer: drawer([
///     navItem("Home",    Icons.home,    onTap: () {}),
///     navItem("Profile", Icons.person,  onTap: () {}),
///   ]),
/// )
/// ```
class VoxDrawer extends StatelessWidget {
  final List<VoxNavItem> items;
  final Widget? header;

  const VoxDrawer(this.items, {super.key, this.header});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (header != null)
            header!
          else
            const DrawerHeader(child: SizedBox.shrink()),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: item.selected,
              onTap: () {
                VoxDrawerController.close();
                item.onTap?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}
