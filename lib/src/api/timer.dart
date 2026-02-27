/// Timer utilities — delay and repeating intervals.
///
/// ```dart
/// // One-shot delay:
/// await delay(const Duration(seconds: 2));
/// delay(const Duration(milliseconds: 300), () => hideSpinner());
///
/// // Repeating interval:
/// final stop = every(const Duration(seconds: 1), () => tick());
/// // later:
/// stop();
/// ```
library;

export '../core/timer/timer_engine.dart' show VoxTimer;

import 'dart:ui' show VoidCallback;

import '../core/timer/timer_engine.dart';

/// Execute [fn] once after [duration].
///
/// If [fn] is omitted, returns a [Future] that completes after [duration].
///
/// ```dart
/// await delay(const Duration(seconds: 2));
/// delay(const Duration(milliseconds: 500), () => setState());
/// ```
Future<void> delay(Duration duration, [VoidCallback? fn]) =>
    VoxTimer.delay(duration, fn);

/// Execute [fn] every [interval]. Returns a cancel function.
///
/// ```dart
/// final stop = every(const Duration(seconds: 1), () => tick());
/// // later:
/// stop();
/// ```
VoidCallback every(Duration interval, VoidCallback fn) =>
    VoxTimer.every(interval, fn);
