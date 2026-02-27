/// Dependency injection — type-based service registration and retrieval.
///
/// ```dart
/// // Register once (in main or voxApp init:)
/// provide<AuthService>(AuthService());
/// provide<ApiClient>(ApiClient(baseUrl: env('API_URL')));
///
/// // Retrieve anywhere — screens, widgets, functions:
/// final auth = use<AuthService>();
/// final api  = use<ApiClient>();
///
/// // Testing — call provide<T> again with a mock:
/// provide<AuthService>(MockAuthService());
/// ```
library;

export '../core/di/container.dart' show VoxContainer;

import '../core/di/container.dart';

/// Register a service instance [T] globally.
///
/// Replaces any previous registration for type [T].
void provide<T extends Object>(T instance) => VoxContainer.provide<T>(instance);

/// Retrieve the registered service of type [T].
///
/// Throws a [VoxError] if [T] was not registered via [provide].
T use<T extends Object>() => VoxContainer.use<T>();

/// Returns `true` if a service of type [T] is registered.
bool has<T extends Object>() => VoxContainer.has<T>();
