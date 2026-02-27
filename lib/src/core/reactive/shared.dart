import 'signal.dart';

/// App-global reactive state. Lives for the app's lifetime,
/// accessible from any screen.
///
/// Fully implemented in a later phase. Stub for now.
class VoxShared<T> extends VoxSignal<T> {
  VoxShared(super.initial);
}
