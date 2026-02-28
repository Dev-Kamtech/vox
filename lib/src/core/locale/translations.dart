/// vox core: translation helpers — convenience types and utilities.
library;

// ---------------------------------------------------------------------------
// VoxTranslationMap — type alias for a single-language translation map
// ---------------------------------------------------------------------------

/// A map of translation keys to their localized strings.
///
/// Used as the value type when passing translations to [VoxLocale.configure].
///
/// ```dart
/// VoxLocale.configure({
///   'en': VoxTranslationMap({
///     'hello': 'Hello',
///     'bye':   'Goodbye',
///   }),
///   'es': VoxTranslationMap({
///     'hello': 'Hola',
///     'bye':   'Adiós',
///   }),
/// });
/// ```
typedef VoxTranslationMap = Map<String, String>;
