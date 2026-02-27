/// Storage API — persistent key-value storage and secure encrypted storage.
///
/// ```dart
/// // Regular storage (SharedPreferences)
/// await save('token', 'abc123');
/// final token = await load('token');   // dynamic — cast as needed
/// await remove('token');
///
/// // Secure storage (platform keychain/keystore)
/// await saveSecure('password', 'secret');
/// final pass = await loadSecure('password');  // String?
/// await removeSecure('password');
///
/// // Reactive persisted state
/// final theme = stored('theme', 'light');  // from api/state.dart
/// theme.set('dark');  // updates UI + saves to disk
/// ```
library;

import '../core/storage/storage.dart';
import '../core/secure/secure.dart';

/// Save [value] to persistent storage under [key].
///
/// Supported types: [String], [int], [double], [bool], [List<String>].
Future<void> save(String key, dynamic value) => VoxStorage.save(key, value);

/// Load the value stored under [key], or null if not set.
///
/// ```dart
/// final token = await load('token') as String?;
/// ```
Future<dynamic> load(String key) => VoxStorage.load(key);

/// Remove the value stored under [key].
Future<void> remove(String key) => VoxStorage.remove(key);

/// Save an encrypted [value] under [key] using platform-native secure storage
/// (Keychain on iOS, Keystore on Android).
Future<void> saveSecure(String key, String value) =>
    VoxSecure.save(key, value);

/// Load the encrypted value for [key], or null if not set.
Future<String?> loadSecure(String key) => VoxSecure.load(key);

/// Remove the encrypted value for [key].
Future<void> removeSecure(String key) => VoxSecure.remove(key);
