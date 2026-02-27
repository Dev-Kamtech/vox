/// vox api: model — base class for JSON-serializable data models.
///
/// ```dart
/// // Define a model:
/// class User extends VoxModel {
///   final String name;
///   final String email;
///
///   const User({required this.name, required this.email});
///
///   @override
///   User fromJson(Map<String, dynamic> json) => User(
///     name:  json['name']  as String,
///     email: json['email'] as String,
///   );
///
///   @override
///   Map<String, dynamic> toJson() => {'name': name, 'email': email};
/// }
///
/// // Parse from JSON:
/// final user = User().fromJson({'name': 'Sam', 'email': 'sam@x.com'});
///
/// // Parse a list:
/// final users = User().listFromJson(jsonList);
///
/// // Serialize:
/// final json = user.toJson();
///
/// // Copy with overrides:
/// final updated = user.copyWith({'name': 'New Name'});
/// ```
library;

export '../core/model/vox_model.dart' show VoxModel;
