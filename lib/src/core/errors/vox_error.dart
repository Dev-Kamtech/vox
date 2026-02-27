/// The single exception type for all developer-facing errors in vox.
///
/// Every error message speaks vox language — references vox functions
/// and classes, never Flutter internals. The `vox:` prefix makes errors
/// instantly recognizable in stack traces.
class VoxError implements Exception {
  /// What went wrong, in vox terms.
  final String message;

  /// Optional hint telling the developer what to do differently.
  final String? hint;

  const VoxError(this.message, {this.hint});

  @override
  String toString() {
    final buffer = StringBuffer('vox: $message');
    if (hint != null) {
      buffer.write('\n     hint: $hint');
    }
    return buffer.toString();
  }
}
