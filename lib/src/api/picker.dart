/// vox api: picker — date, time, and option pickers.
///
/// ```dart
/// // Date picker
/// final date = await pickDate();
/// final date = await pickDate(initial: DateTime(2024, 1, 1));
///
/// // Time picker
/// final time = await pickTime();
///
/// // Single-select from a list
/// final country = await pickOne(['US', 'UK', 'CA'], label: (c) => c);
///
/// // Multi-select from a list
/// final tags = await pickMany(
///   ['Dart', 'Flutter', 'Rust'],
///   initial: ['Dart'],
///   label: (t) => t,
/// );
/// ```
library;

export '../core/picker/picker_engine.dart'
    show pickDate, pickTime, pickOne, pickMany;
