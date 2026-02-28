/// vox api: share — native share sheet.
///
/// ```dart
/// await shareText("Check this out!");
/// await shareLink("https://example.com", subject: "Cool site");
/// await shareFiles(["/path/to/image.png"], subject: "Photo");
/// ```
library;

export '../core/share/share_engine.dart' show VoxShare;

import '../core/share/share_engine.dart';

/// Share plain [text] via the native share sheet.
Future<void> shareText(String text, {String? subject}) =>
    VoxShare.text(text, subject: subject);

/// Share a [url] via the native share sheet.
Future<void> shareLink(String url, {String? subject}) =>
    VoxShare.link(url, subject: subject);

/// Share one or more files by absolute [paths] via the native share sheet.
Future<void> shareFiles(List<String> paths,
        {String? subject, String? text}) =>
    VoxShare.files(paths, subject: subject, text: text);
