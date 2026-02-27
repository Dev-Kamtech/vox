/// Clipboard read and write.
///
/// ```dart
/// await copy('Hello world');
///
/// final text = await paste();
/// if (text != null) log.i('Pasted: $text');
/// ```
library;

export '../core/clipboard/clipboard_engine.dart' show VoxClipboard;

import '../core/clipboard/clipboard_engine.dart';

/// Copy [text] to the system clipboard.
///
/// ```dart
/// await copy(user.email);
/// toast('Copied!', type: VoxToastType.success);
/// ```
Future<void> copy(String text) => VoxClipboard.copy(text);

/// Read text from the system clipboard.
///
/// Returns `null` if the clipboard is empty or contains non-text data.
///
/// ```dart
/// final text = await paste();
/// if (text != null) emailField.set(text);
/// ```
Future<String?> paste() => VoxClipboard.paste();
