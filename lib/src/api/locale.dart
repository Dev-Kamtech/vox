/// vox api: locale — runtime internationalization and translation.
///
/// ```dart
/// // At startup:
/// VoxLocale.configure({
///   'en': {'greeting': 'Hello', 'welcome': 'Welcome, {name}!'},
///   'fr': {'greeting': 'Bonjour', 'welcome': 'Bienvenue, {name} !'},
/// });
///
/// // Switch language:
/// VoxLocale.set('fr');
///
/// // Use anywhere — no context needed:
/// label(t('greeting'))                    // 'Bonjour'
/// label(t('welcome', {'name': 'Marie'}))  // 'Bienvenue, Marie !'
/// ```
library;

export '../core/locale/locale_engine.dart' show VoxLocale, t;
export '../core/locale/translations.dart' show VoxTranslationMap;
