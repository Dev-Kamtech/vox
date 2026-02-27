/// Lifecycle hooks for VoxScreen.
///
/// All hooks are optional — override only what you need.
/// Called automatically by the internal State object.
mixin VoxLifecycle {
  /// Called once after the screen is first mounted and rendered.
  void ready() {}

  /// Called when navigating back to this screen (it was paused, now resumed).
  void resume() {}

  /// Called when another screen is pushed on top of this one.
  void pause() {}

  /// Called when the app goes to the background (e.g., user switches apps).
  void background() {}

  /// Called when the app returns to the foreground.
  void foreground() {}

  /// Called when the screen is permanently removed from the tree.
  void onDispose() {}
}
