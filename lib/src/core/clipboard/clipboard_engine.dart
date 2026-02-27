import 'package:flutter/services.dart';

/// Clipboard read/write. Uses Flutter's platform channel — no permissions needed.
abstract final class VoxClipboard {
  /// Copy [text] to the system clipboard.
  static Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  /// Read text from the system clipboard.
  ///
  /// Returns `null` if the clipboard is empty or contains non-text data.
  static Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
