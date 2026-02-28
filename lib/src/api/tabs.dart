/// vox api: tabs — bottom navigation and top tab bar.
///
/// ```dart
/// // Bottom navigation tabs
/// class App extends VoxScreen {
///   @override
///   get view => tabs([
///     tab("Home",    Icons.home,    HomeScreen()),
///     tab("Profile", Icons.person,  ProfileScreen()),
///   ]);
/// }
///
/// // Top tab bar (replaces screen())
/// class App extends VoxScreen {
///   @override
///   get view => topTabs("My App", [
///     tab("All",    null, allContent),
///     tab("Active", null, activeContent),
///   ]);
/// }
/// ```
library;

export '../core/tabs/tab_engine.dart' show VoxTab, VoxBottomTabs, VoxTopTabs;

import 'package:flutter/material.dart';

import '../core/tabs/tab_engine.dart';

/// Create a [VoxTab] descriptor used in [tabs] or [topTabs].
///
/// [icon] is optional — used for bottom navigation bar items.
VoxTab tab(String label, IconData? icon, Widget body) =>
    VoxTab(label: label, icon: icon, body: body);

/// Create a bottom navigation tab widget from [items].
///
/// [initial] sets the starting tab index (default `0`).
/// [activeColor] / [inactiveColor] override the theme defaults.
VoxBottomTabs tabs(
  List<VoxTab> items, {
  int initial = 0,
  Color? activeColor,
  Color? inactiveColor,
}) =>
    VoxBottomTabs(
      items,
      initial: initial,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );

/// Create a top tab bar screen with [title] and [items].
///
/// Renders a [Scaffold] with [AppBar] + [TabBar] + [TabBarView].
VoxTopTabs topTabs(
  String title,
  List<VoxTab> items, {
  List<Widget>? actions,
}) =>
    VoxTopTabs(title, items, actions: actions);
