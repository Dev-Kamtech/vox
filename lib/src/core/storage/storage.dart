import 'package:shared_preferences/shared_preferences.dart';

/// Key-value persistent storage. Wraps [SharedPreferences].
///
/// Used by the [save], [load], [remove] top-level API functions.
/// Supports [String], [int], [double], [bool], [List<String>].
abstract final class VoxStorage {
  /// Persist [value] under [key].
  static Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  /// Read the value stored under [key], or null if not set.
  static Future<dynamic> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  /// Remove the value stored under [key].
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Remove all stored values.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
