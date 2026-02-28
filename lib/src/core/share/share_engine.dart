/// vox core: share engine — native share sheet via share_plus.
library;

import 'package:share_plus/share_plus.dart';

// ---------------------------------------------------------------------------
// VoxShare — static facade for sharing content
// ---------------------------------------------------------------------------

/// Wraps [share_plus] for native sharing. Accessed via `api/share.dart`.
///
/// ```dart
/// VoxShare.text("Check this out!");
/// VoxShare.link("https://example.com", subject: "Cool site");
/// ```
abstract final class VoxShare {
  /// Share plain text content via the native share sheet.
  static Future<void> text(
    String content, {
    String? subject,
  }) async {
    await Share.share(content, subject: subject);
  }

  /// Share a URL via the native share sheet.
  static Future<void> link(
    String url, {
    String? subject,
  }) async {
    await Share.share(url, subject: subject);
  }

  /// Share one or more files via the native share sheet.
  ///
  /// [paths] is a list of absolute file paths.
  static Future<void> files(
    List<String> paths, {
    String? subject,
    String? text,
  }) async {
    await Share.shareXFiles(
      paths.map(XFile.new).toList(),
      subject: subject,
      text: text,
    );
  }
}
