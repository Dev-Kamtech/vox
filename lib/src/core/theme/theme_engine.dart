import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// VoxTheme — design token container
// ---------------------------------------------------------------------------

/// App-wide visual design tokens.
///
/// Pass to [voxApp] via the `theme:` parameter. The system automatically
/// generates [ThemeData] from these tokens and handles dark mode.
///
/// ```dart
/// void main() => voxApp(
///   home: HomeScreen(),
///   theme: VoxTheme(
///     primary: Color(0xFF6C63FF),
///     background: Color(0xFFF5F5F5),
///     surface: Colors.white,
///     text: Color(0xFF1A1A2E),
///     radius: 12.0,
///     dark: VoxTheme.dark(),
///   ),
/// );
/// ```
class VoxTheme {
  /// Brand / accent color.
  final Color primary;

  /// Scaffold / page background.
  final Color background;

  /// Card / surface color.
  final Color surface;

  /// Default body text color.
  final Color text;

  /// Error color (defaults to Material red).
  final Color? error;

  /// Default border radius used by cards, buttons, and inputs.
  final double radius;

  /// Optional dark-mode variant.
  final VoxTheme? dark;

  const VoxTheme({
    this.primary = const Color(0xFF6C63FF),
    this.background = const Color(0xFFF5F5F5),
    this.surface = Colors.white,
    this.text = const Color(0xFF1A1A2E),
    this.error,
    this.radius = 12.0,
    this.dark,
  });

  /// Deep navy dark theme.
  factory VoxTheme.dark() => const VoxTheme(
        primary: Color(0xFF6C63FF),
        background: Color(0xFF1A1A2E),
        surface: Color(0xFF2A2A3E),
        text: Colors.white,
        radius: 12.0,
      );

  /// Light theme (same as the unnamed constructor).
  factory VoxTheme.light() => const VoxTheme();

  /// Follows the device's dark/light mode setting automatically.
  factory VoxTheme.system() => VoxTheme(dark: VoxTheme.dark());

  /// Convert to a Flutter [ThemeData] for the given [brightness].
  ThemeData toMaterial({Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;
    final active = isDark && dark != null ? dark! : this;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: active.primary,
        brightness: brightness,
        surface: active.surface,
        error: active.error ??
            (isDark
                ? const Color(0xFFCF6679)
                : const Color(0xFFB00020)),
      ),
      scaffoldBackgroundColor: active.background,
      cardColor: active.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(active.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(active.radius),
        ),
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(bodyColor: active.text, displayColor: active.text),
    );
  }
}

// ---------------------------------------------------------------------------
// VoxThemeController — runtime theme management
// ---------------------------------------------------------------------------

/// Controls the active theme at runtime.
///
/// Access via `vox.theme` (global accessor from `api/device.dart`).
///
/// ```dart
/// vox.theme.toggle()              // dark ↔ light
/// vox.theme.set(VoxTheme.dark())  // explicit override
/// vox.theme.primary               // current primary color
/// ```
class VoxThemeController extends ChangeNotifier {
  VoxThemeController._();

  static final VoxThemeController _singleton = VoxThemeController._();

  /// The app-wide singleton instance.
  static VoxThemeController get instance => _singleton;

  VoxTheme _theme = const VoxTheme();
  ThemeMode _mode = ThemeMode.system;

  // ---------------------------------------------------------------------------
  // Internal — called from vox_app.dart
  // ---------------------------------------------------------------------------

  /// Apply a [VoxTheme] from [voxApp]'s `theme:` parameter.
  void configure(VoxTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// The current [ThemeMode] (light / dark / system).
  ThemeMode get mode => _mode;

  /// Toggle between [ThemeMode.light] and [ThemeMode.dark].
  void toggle() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Replace the active theme entirely.
  void set(VoxTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Token shortcuts (vox.theme.primary, vox.theme.text, etc.)
  // ---------------------------------------------------------------------------

  /// Primary brand color.
  Color get primary => _theme.primary;

  /// Scaffold / page background color.
  Color get background => _theme.background;

  /// Card / surface color.
  Color get surface => _theme.surface;

  /// Default body text color.
  Color get text => _theme.text;

  /// Default border radius.
  double get radius => _theme.radius;

  // ---------------------------------------------------------------------------
  // Internal — consumed by vox_app.dart to build MaterialApp
  // ---------------------------------------------------------------------------

  /// Light [ThemeData] derived from the active [VoxTheme].
  ThemeData get lightTheme =>
      _theme.toMaterial(brightness: Brightness.light);

  /// Dark [ThemeData] from [VoxTheme.dark], or null if not configured.
  ThemeData? get darkTheme =>
      _theme.dark?.toMaterial(brightness: Brightness.dark);
}
