import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../errors/vox_error.dart';
import '../reactive/signal.dart';

/// A chainable, pipeable HTTP request.
///
/// Returned by [fetch], [post], [put], [patch], [delete]. Implements [Future<T>]
/// so it can be `await`ed directly. The `>>` operator pipes the result into
/// a vox signal — ideal for loading data into state on screen ready.
///
/// ```dart
/// // Fire-and-forget into state
/// fetch("https://api.example.com/todos") >> todos;
///
/// // With loading indicator and error handling
/// fetch("https://api.example.com/todos")
///   .loading(isLoading)
///   .onError((e) => errorMsg.set('$e'))
///   >> todos;
///
/// // Await directly
/// final user = await fetch("https://api.example.com/me");
///
/// // Manual in ready()
/// @override
/// void ready() => fetch(url).loading(loading) >> data;
/// ```
class VoxRequest<T> implements Future<T> {
  final Future<T> _future;
  VoxSignal<bool>? _loadingSignal;
  void Function(Object error)? _errorCallback;

  VoxRequest(this._future);

  /// Show a loading indicator while the request runs.
  ///
  /// Sets [signal] to `true` before the request and `false` when done.
  ///
  /// ```dart
  /// fetch(url).loading(isLoading) >> todos;
  /// ```
  VoxRequest<T> loading(VoxSignal<bool> signal) {
    _loadingSignal = signal;
    return this;
  }

  /// Handle errors from this request.
  ///
  /// If not provided, errors are printed in debug mode and swallowed in release.
  ///
  /// ```dart
  /// fetch(url).onError((e) => errorMsg.set('Load failed: $e')) >> todos;
  /// ```
  VoxRequest<T> onError(void Function(Object error) handler) {
    _errorCallback = handler;
    return this;
  }

  /// Pipe the result into a vox signal. Fire-and-forget.
  ///
  /// [target] must be a signal created with `state()`, `shared()`, or `stored()`.
  ///
  /// ```dart
  /// fetch(url) >> todos;        // result → todos
  /// post(url, body: data) >> response;
  /// ```
  void operator >>(Object target) {
    if (target is! VoxSignal) {
      throw VoxError(
        '>> target must be a state signal. Got: ${target.runtimeType}',
        hint: 'Use: fetch(url) >> myState  '
            'where myState was created with state(), shared(), or stored()',
      );
    }
    _pipe(target);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _pipe(VoxSignal target) async {
    _loadingSignal?.set(true);
    try {
      final result = await _future;
      // ignore: avoid_dynamic_calls
      (target as dynamic).set(result);
    } catch (e, stack) {
      if (_errorCallback != null) {
        _errorCallback!(e);
      } else if (kDebugMode) {
        debugPrint('vox: unhandled HTTP error — $e\n$stack');
      }
    } finally {
      _loadingSignal?.set(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Future<T> — delegate everything to _future so `await fetch(url)` works
  // ---------------------------------------------------------------------------

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);

  @override
  Future<T> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) =>
      _future.catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  Future<T> timeout(
    Duration timeLimit, {
    FutureOr<T> Function()? onTimeout,
  }) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

}
