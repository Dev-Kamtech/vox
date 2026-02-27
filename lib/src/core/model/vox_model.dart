/// vox core: VoxModel — base class for JSON-serializable data models.
library;

// ---------------------------------------------------------------------------
// VoxModel
// ---------------------------------------------------------------------------

/// Base class for data models with JSON serialization.
///
/// Extend this class to create type-safe, JSON-aware data models
/// that integrate cleanly with vox's networking layer.
///
/// ```dart
/// class User extends VoxModel {
///   final String name;
///   final String email;
///   final int age;
///
///   const User({required this.name, required this.email, required this.age});
///
///   @override
///   User fromJson(Map<String, dynamic> json) => User(
///     name:  json['name']  as String,
///     email: json['email'] as String,
///     age:   json['age']   as int,
///   );
///
///   @override
///   Map<String, dynamic> toJson() => {
///     'name':  name,
///     'email': email,
///     'age':   age,
///   };
/// }
/// ```
///
/// Once defined, use with `fetch()`:
/// ```dart
/// final user = state<User?>(null);
/// fetch('https://api.com/me').model(User()) >> user;
/// ```
abstract class VoxModel {
  const VoxModel();

  /// Create a new instance of this model from a [json] map.
  ///
  /// Implement this as a factory that returns the concrete subtype:
  /// ```dart
  /// @override
  /// User fromJson(Map<String, dynamic> json) => User(name: json['name']);
  /// ```
  VoxModel fromJson(Map<String, dynamic> json);

  /// Convert this model to a JSON map.
  ///
  /// ```dart
  /// @override
  /// Map<String, dynamic> toJson() => {'name': name, 'email': email};
  /// ```
  Map<String, dynamic> toJson();

  /// Parse a list of JSON objects into a list of this model type.
  ///
  /// ```dart
  /// final users = User().listFromJson(jsonList);
  /// ```
  List<T> listFromJson<T extends VoxModel>(List<dynamic> jsonList) {
    return jsonList
        .map((item) => fromJson(item as Map<String, dynamic>) as T)
        .toList();
  }

  /// Deep-copy this model with updated fields via [toJson] / [fromJson].
  ///
  /// ```dart
  /// final updated = user.copyWith({'name': 'New Name'});
  /// ```
  T copyWith<T extends VoxModel>(Map<String, dynamic> overrides) {
    final json = {...toJson(), ...overrides};
    return fromJson(json) as T;
  }

  @override
  String toString() => 'VoxModel(${toJson()})';

  @override
  bool operator ==(Object other) =>
      other is VoxModel && other.toJson().toString() == toJson().toString();

  @override
  int get hashCode => toJson().toString().hashCode;
}
