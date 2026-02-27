/// vox core: i18n engine — runtime locale and translation lookup.
library;

import '../errors/vox_error.dart';

// ---------------------------------------------------------------------------
// VoxLocale — translation registry and locale controller
// ---------------------------------------------------------------------------

/// Runtime internationalization engine.
///
/// Configure translations at startup, then call [t] anywhere to look up keys.
///
/// ```dart
/// // At startup (main or voxApp init:):
/// VoxLocale.configure({
///   'en': {
///     'greeting':  'Hello',
///     'welcome':   'Welcome, {name}!',
///     'item_count': '{count} items',
///   },
///   'fr': {
///     'greeting':  'Bonjour',
///     'welcome':   'Bienvenue, {name} !',
///     'item_count': '{count} éléments',
///   },
/// });
///
/// // Optionally set the initial language (default is 'en'):
/// VoxLocale.set('fr');
///
/// // Anywhere in your app:
/// label(t('greeting'))                     // 'Bonjour'
/// label(t('welcome', {'name': 'Marie'}))   // 'Bienvenue, Marie !'
/// ```
abstract final class VoxLocale {
  static String _lang = 'en';
  static String _fallback = 'en';
  static Map<String, Map<String, String>> _translations = {};

  // -- Setup ----------------------------------------------------------------

  /// Register all translations and optional [fallback] language.
  ///
  /// [fallback] is used when a key is missing in the current language.
  /// Defaults to `'en'`.
  ///
  /// Can be called multiple times — later values overwrite earlier ones.
  static void configure(
    Map<String, Map<String, String>> translations, {
    String fallback = 'en',
  }) {
    _translations = {..._translations, ...translations};
    _fallback = fallback;
  }

  // -- Language control -----------------------------------------------------

  /// Switch the active language.
  ///
  /// Call with a language code you registered via [configure].
  /// Throws a [VoxError] in debug mode if the language is not configured.
  static void set(String lang) {
    assert(
      _translations.containsKey(lang),
      'vox: VoxLocale.set("$lang") — language "$lang" is not configured. '
      'Available: ${_translations.keys.join(', ')}. '
      'Call VoxLocale.configure() before set().',
    );
    _lang = lang;
  }

  /// The currently active language code.
  static String get current => _lang;

  /// All configured language codes.
  static List<String> get available => _translations.keys.toList();

  /// Whether translations have been configured.
  static bool get isConfigured => _translations.isNotEmpty;

  // -- Translation ----------------------------------------------------------

  /// Translate [key] in the current language.
  ///
  /// [args] are substituted as `{key}` placeholders in the translated string.
  ///
  /// Falls back to [_fallback] language if key is missing in [_lang].
  /// Falls back to [key] itself if not found in any language.
  static String translate(String key, [Map<String, dynamic>? args]) {
    final primary = _translations[_lang];
    final fallback = _translations[_fallback];

    String result = primary?[key] ?? fallback?[key] ?? key;

    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        result = result.replaceAll('{$k}', '$v');
      });
    }

    return result;
  }

  // -- Utilities ------------------------------------------------------------

  /// Reset all translations and revert to default language.
  /// Useful in tests.
  static void clear() {
    _translations = {};
    _lang = 'en';
    _fallback = 'en';
  }
}

// ---------------------------------------------------------------------------
// t() — top-level translation function
// ---------------------------------------------------------------------------

/// Translate [key] in the current language.
///
/// [args] maps placeholder names to values:
/// - `t('welcome', {'name': 'Sam'})` → `'Hello, Sam!'`
/// - `t('item_count', {'count': 3})` → `'3 items'`
///
/// Returns [key] itself if the translation is not found.
String t(String key, [Map<String, dynamic>? args]) =>
    VoxLocale.translate(key, args);
