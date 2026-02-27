/// App-wide theming — design tokens + runtime dark/light switching.
///
/// ```dart
/// void main() => voxApp(
///   home: HomeScreen(),
///   theme: VoxTheme(
///     primary:    Color(0xFF6C63FF),
///     background: Color(0xFFF5F5F5),
///     surface:    Colors.white,
///     text:       Color(0xFF1A1A2E),
///     radius:     12.0,
///     dark: VoxTheme.dark(),    // auto dark mode
///   ),
/// );
///
/// // Access anywhere via vox.theme:
/// vox.theme.primary          // active primary color
/// vox.theme.toggle()         // switch dark ↔ light
/// vox.theme.set(VoxTheme.dark())
/// ```
library;

export '../core/theme/theme_engine.dart' show VoxTheme, VoxThemeController;
