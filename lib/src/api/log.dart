/// Leveled console logger.
///
/// ```dart
/// log.d('fetching user');           // debug (debug builds only)
/// log.i('user loaded: ${user.id}'); // info
/// log.w('token expiring soon');     // warning
/// log.e('login failed', error);     // error + exception
/// ```
library;

export '../core/log/logger.dart' show VoxLog, log;
