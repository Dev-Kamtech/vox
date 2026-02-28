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
///   User decode(Map<String, dynamic> j) => User(
///     name:  j.str('name'),
///     email: j.str('email'),
///   );
///
///   @override
///   Map<String, dynamic> encode() => {'name': name, 'email': email};
/// }
///
/// // Parse from JSON:
/// final user = User().decode({'name': 'Sam', 'email': 'sam@x.com'});
///
/// // Parse a list:
/// final users = User().decodeAll(jsonList);
///
/// // Serialize:
/// final json = user.encode();
///
/// // Copy with overrides:
/// final updated = user.copyWith({'name': 'New Name'});
///
/// // Map accessor helpers (VoxData extension):
/// j.str('name')       // String, default ''
/// j.flag('active')    // bool, default false
/// j.n('age')          // int, default 0
/// j.dec('price')      // double, default 0.0
/// j.arr('tags')       // List, default []
/// j.obj('meta')       // Map, default {}
/// j.date('createdAt') // DateTime, default now
/// ```
library;

export '../core/model/vox_model.dart' show VoxModel, VoxData;
