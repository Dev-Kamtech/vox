import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage. Wraps [FlutterSecureStorage].
///
/// Used by the [saveSecure], [loadSecure], [removeSecure] top-level API functions.
/// Values are stored using platform-native encryption (Keychain on iOS,
/// Keystore on Android).
abstract final class VoxSecure {
  static const _storage = FlutterSecureStorage();

  /// Save an encrypted [value] under [key].
  static Future<void> save(String key, String value) =>
      _storage.write(key: key, value: value);

  /// Read the encrypted value for [key], or null if not set.
  static Future<String?> load(String key) => _storage.read(key: key);

  /// Remove the encrypted value for [key].
  static Future<void> remove(String key) => _storage.delete(key: key);

  /// Remove all encrypted values.
  static Future<void> clear() => _storage.deleteAll();
}
