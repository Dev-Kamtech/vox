import 'package:shared_preferences/shared_preferences.dart';

import 'state.dart';

/// Reactive state that also persists to local storage (SharedPreferences).
///
/// Behaves exactly like [VoxState] — screens that read [val] rebuild when
/// the value changes. Additionally, every [set] / [update] call is saved to
/// disk automatically, and the persisted value is restored on next app launch.
///
/// Supported types: [String], [int], [double], [bool], [List<String>].
///
/// ```dart
/// final theme  = stored('theme', 'light');
/// final count  = stored('count', 0);
/// final agreed = stored('agreed', false);
///
/// theme.val              // read (tracked, reactive)
/// theme.set('dark')      // update + persist
/// theme.update((v) => v == 'light' ? 'dark' : 'light')
/// await theme.clear()    // remove from storage, revert to default
/// ```
class VoxStored<T> extends VoxState<T> {
  final String _key;
  final T _defaultValue;

  VoxStored(this._key, this._defaultValue) : super(_defaultValue) {
    _load();
  }

  /// Load the persisted value from storage. Fire-and-forget — the screen
  /// rebuilds automatically once the value is loaded via set().
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = _readFrom(prefs);
    if (value != null) super.set(value); // super: skip re-persisting on load
  }

  /// Override set() to also persist the new value.
  @override
  void set(T newValue) {
    super.set(newValue);
    _persist(newValue); // async, fire-and-forget
  }

  /// Override update() so transforms also go through the persisting set().
  @override
  void update(T Function(T current) updater) {
    set(updater(peek));
  }

  /// Remove the stored key and revert to the default value.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    super.set(_defaultValue); // super: clearing doesn't need to re-persist
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _persist(T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(_key, value);
    } else if (value is int) {
      await prefs.setInt(_key, value);
    } else if (value is double) {
      await prefs.setDouble(_key, value);
    } else if (value is bool) {
      await prefs.setBool(_key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(_key, value);
    }
  }

  T? _readFrom(SharedPreferences prefs) {
    final def = _defaultValue;
    if (def is String) return prefs.getString(_key) as T?;
    if (def is int) return prefs.getInt(_key) as T?;
    if (def is double) return prefs.getDouble(_key) as T?;
    if (def is bool) return prefs.getBool(_key) as T?;
    if (def is List<String>) return prefs.getStringList(_key) as T?;
    return null;
  }
}
