/// vox core: tab engine — bottom navigation tabs and top tab bar.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// VoxTab — data class for a single tab entry
// ---------------------------------------------------------------------------

/// A tab descriptor — label, optional icon, and body widget.
///
/// Created via the `tab()` factory in `api/tabs.dart`.
class VoxTab {
  final String label;
  final IconData? icon;
  final Widget body;

  const VoxTab({required this.label, this.icon, required this.body});
}

// ---------------------------------------------------------------------------
// VoxBottomTabs — bottom navigation bar (tabs())
// ---------------------------------------------------------------------------

/// Bottom navigation widget. Created by `tabs([])` in `api/tabs.dart`.
///
/// Uses an [IndexedStack] to preserve state across tab switches.
/// Each tab can be any widget — screen, col, row, etc.
class VoxBottomTabs extends StatefulWidget {
  final List<VoxTab> tabs;
  final int initial;
  final Color? activeColor;
  final Color? inactiveColor;

  const VoxBottomTabs(
    this.tabs, {
    super.key,
    this.initial = 0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<VoxBottomTabs> createState() => _VoxBottomTabsState();
}

class _VoxBottomTabsState extends State<VoxBottomTabs> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial.clamp(0, widget.tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _current,
        children: widget.tabs.map((t) => t.body).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        selectedItemColor: widget.activeColor,
        unselectedItemColor: widget.inactiveColor,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _current = i),
        items: widget.tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.icon ?? Icons.circle_outlined),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VoxTopTabs — top tab bar (topTabs())
// ---------------------------------------------------------------------------

/// Top tab bar widget. Created by `topTabs()` in `api/tabs.dart`.
///
/// Renders a [Scaffold] with an [AppBar] containing a [TabBar] bottom
/// and a [TabBarView] body.
class VoxTopTabs extends StatelessWidget {
  final String title;
  final List<VoxTab> tabs;
  final List<Widget>? actions;

  const VoxTopTabs(
    this.title,
    this.tabs, {
    super.key,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
          bottom: TabBar(
            tabs: tabs
                .map(
                  (t) => Tab(
                    text: t.label,
                    icon: t.icon != null ? Icon(t.icon) : null,
                  ),
                )
                .toList(),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: tabs.map((t) => t.body).toList(),
          ),
        ),
      ),
    );
  }
}
