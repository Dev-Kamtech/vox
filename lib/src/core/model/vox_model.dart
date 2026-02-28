/// vox core: VoxModel — base class for JSON-serializable data models.
library;

// ---------------------------------------------------------------------------
// VoxModel
// ---------------------------------------------------------------------------

/// Base class for data models with JSON decode/encode.
///
/// Extend this to create type-safe models that work with vox's HTTP layer.
///
/// ```dart
/// class User extends VoxModel {
///   final String name;
///   final String email;
///
///   const User({required this.name, required this.email});
///
///   @override
///   User decode(Map<String, dynamic> j) => User(
///     name:  j.str('name'),
///     email: j.str('email'),
///   );
///
///   @override
///   Map<String, dynamic> encode() => {'name': name, 'email': email};
/// }
/// ```
///
/// Use with `fetch()`:
/// ```dart
/// final user = state<User?>(null);
/// fetch('https://api.com/me').model(User()) >> user;
/// ```
abstract class VoxModel {
  const VoxModel();

  /// Create an instance from a decoded JSON map.
  ///
  /// ```dart
  /// @override
  /// User decode(Map<String, dynamic> j) => User(name: j.str('name'));
  /// ```
  VoxModel decode(Map<String, dynamic> json);

  /// Convert this model to a JSON map.
  ///
  /// ```dart
  /// @override
  /// Map<String, dynamic> encode() => {'name': name, 'email': email};
  /// ```
  Map<String, dynamic> encode();

  /// Parse a list of JSON objects into typed models.
  ///
  /// ```dart
  /// final users = User().decodeAll(jsonList);
  /// ```
  List<T> decodeAll<T extends VoxModel>(List<dynamic> list) =>
      list.map((e) => decode(e as Map<String, dynamic>) as T).toList();

  /// Deep-copy this model with updated fields.
  ///
  /// ```dart
  /// final updated = user.copyWith({'name': 'New Name'});
  /// ```
  T copyWith<T extends VoxModel>(Map<String, dynamic> overrides) =>
      decode({...encode(), ...overrides}) as T;

  @override
  String toString() => 'VoxModel(${encode()})';

  @override
  bool operator ==(Object other) =>
      other is VoxModel &&
      other.encode().toString() == encode().toString();

  @override
  int get hashCode => encode().toString().hashCode;
}

// ---------------------------------------------------------------------------
// VoxData — Map accessor helpers
// ---------------------------------------------------------------------------

/// Convenience extension for reading typed values from a JSON map.
///
/// Eliminates verbose casting and provides safe defaults.
///
/// ```dart
/// final name = j.str('name');          // String, default ''
/// final age  = j.n('age');             // int, default 0
/// final ok   = j.flag('active');       // bool, default false
/// final price = j.dec('price');        // double, default 0.0
/// final tags  = j.arr('tags');         // List, default []
/// final meta  = j.obj('meta');         // Map, default {}
/// final date  = j.date('createdAt');   // DateTime, default now
/// ```
extension VoxData on Map<String, dynamic> {
  /// Read a String value (defaults to '').
  String str(String key, [String fallback = '']) =>
      (this[key] as String?) ?? fallback;

  /// Read a bool value (defaults to false).
  bool flag(String key, [bool fallback = false]) =>
      (this[key] as bool?) ?? fallback;

  /// Read an int value (defaults to 0).
  int n(String key, [int fallback = 0]) =>
      (this[key] as num?)?.toInt() ?? fallback;

  /// Read a double value (defaults to 0.0).
  double dec(String key, [double fallback = 0.0]) =>
      (this[key] as num?)?.toDouble() ?? fallback;

  /// Read a List (defaults to empty list).
  List<dynamic> arr(String key) => (this[key] as List<dynamic>?) ?? [];

  /// Read a nested Map (defaults to empty map).
  Map<String, dynamic> obj(String key) =>
      (this[key] as Map<String, dynamic>?) ?? {};

  /// Read a DateTime from an ISO 8601 string (defaults to now).
  DateTime date(String key) =>
      DateTime.tryParse(this[key] as String? ?? '') ?? DateTime.now();
}
