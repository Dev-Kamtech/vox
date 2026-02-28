import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// label() → VoxLabel
// ---------------------------------------------------------------------------

/// A text widget with chainable text-styling methods.
///
/// Instance methods (`.bold`, `.italic`, `.size()`, `.color()`) return
/// a new [VoxLabel] with modified style. Since VoxLabel extends
/// StatelessWidget, all Widget extensions (`.pad()`, `.center`) also work.
///
/// ```dart
/// label('Hello').bold.size(24).color(Colors.red).pad(all: 16)
/// ```
class VoxLabel extends StatelessWidget {
  final String text;
  final TextStyle _style;
  final TextAlign? _textAlign;
  final int? _maxLines;
  final TextOverflow? _overflow;

  const VoxLabel(
    this.text, {
    super.key,
    TextStyle style = const TextStyle(),
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  })  : _style = style,
        _textAlign = textAlign,
        _maxLines = maxLines,
        _overflow = overflow;

  // -- Text-specific methods (return new VoxLabel with modified style) --

  /// Bold text (700).
  VoxLabel get bold => _copyWith(
      style: _style.copyWith(fontWeight: FontWeight.bold));

  /// Semi-bold text (600).
  VoxLabel get semibold =>
      _copyWith(style: _style.copyWith(fontWeight: FontWeight.w600));

  /// Medium weight text (500).
  VoxLabel get medium =>
      _copyWith(style: _style.copyWith(fontWeight: FontWeight.w500));

  /// Heavy / extra-bold text (800).
  VoxLabel get heavy =>
      _copyWith(style: _style.copyWith(fontWeight: FontWeight.w800));

  /// Thin / light text (300).
  VoxLabel get thin =>
      _copyWith(style: _style.copyWith(fontWeight: FontWeight.w300));

  /// Italic text.
  VoxLabel get italic => _copyWith(
      style: _style.copyWith(fontStyle: FontStyle.italic));

  /// Set font size.
  VoxLabel size(double s) => _copyWith(
      style: _style.copyWith(fontSize: s));

  /// Set text color.
  VoxLabel color(Color c) => _copyWith(
      style: _style.copyWith(color: c));

  /// Set text alignment.
  VoxLabel textAlign(TextAlign a) => _copyWith(textAlign: a);

  /// Set max lines before truncation.
  VoxLabel maxLines(int n) => _copyWith(maxLines: n);

  /// Ellipsis overflow.
  VoxLabel get ellipsis => _copyWith(overflow: TextOverflow.ellipsis);

  /// Underline decoration.
  VoxLabel get underline => _copyWith(
      style: _style.copyWith(decoration: TextDecoration.underline));

  /// Strikethrough decoration.
  VoxLabel get strikethrough => _copyWith(
      style: _style.copyWith(decoration: TextDecoration.lineThrough));

  /// Set font weight directly.
  VoxLabel weight(FontWeight w) => _copyWith(
      style: _style.copyWith(fontWeight: w));

  /// Set letter spacing.
  VoxLabel letterSpacing(double s) => _copyWith(
      style: _style.copyWith(letterSpacing: s));

  VoxLabel _copyWith({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return VoxLabel(
      text,
      style: style ?? _style,
      textAlign: textAlign ?? _textAlign,
      maxLines: maxLines ?? _maxLines,
      overflow: overflow ?? _overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _style,
      textAlign: _textAlign,
      maxLines: _maxLines,
      overflow: _overflow,
    );
  }
}

// ---------------------------------------------------------------------------
// btn() → VoxButton
// ---------------------------------------------------------------------------

/// Button style variants.
enum VoxButtonVariant { elevated, outlined, text }

/// A button with chainable configuration.
///
/// ```dart
/// btn('Save').onTap(() => save()).outline
/// ```
class VoxButton extends StatelessWidget {
  final String text;
  final VoidCallback? _onTap;
  final VoxButtonVariant _variant;
  final Widget? _icon;

  const VoxButton(
    this.text, {
    super.key,
    VoidCallback? onTap,
    VoxButtonVariant variant = VoxButtonVariant.elevated,
    Widget? icon,
  })  : _onTap = onTap,
        _variant = variant,
        _icon = icon;

  /// Set the tap handler.
  VoxButton onTap(VoidCallback callback) =>
      VoxButton(text, onTap: callback, variant: _variant, icon: _icon);

  /// Outlined button style.
  VoxButton get outline =>
      VoxButton(text, onTap: _onTap, variant: VoxButtonVariant.outlined, icon: _icon);

  /// Text-only button style (flat).
  VoxButton get flat =>
      VoxButton(text, onTap: _onTap, variant: VoxButtonVariant.text, icon: _icon);

  /// Add a leading icon.
  VoxButton withIcon(IconData iconData) =>
      VoxButton(text, onTap: _onTap, variant: _variant, icon: Icon(iconData));

  @override
  Widget build(BuildContext context) {
    final child = Text(text);
    final iconWidget = _icon;

    switch (_variant) {
      case VoxButtonVariant.elevated:
        if (iconWidget != null) {
          return ElevatedButton.icon(
              onPressed: _onTap, icon: iconWidget, label: child);
        }
        return ElevatedButton(onPressed: _onTap, child: child);

      case VoxButtonVariant.outlined:
        if (iconWidget != null) {
          return OutlinedButton.icon(
              onPressed: _onTap, icon: iconWidget, label: child);
        }
        return OutlinedButton(onPressed: _onTap, child: child);

      case VoxButtonVariant.text:
        if (iconWidget != null) {
          return TextButton.icon(
              onPressed: _onTap, icon: iconWidget, label: child);
        }
        return TextButton(onPressed: _onTap, child: child);
    }
  }
}

// ---------------------------------------------------------------------------
// Simple widget functions
// ---------------------------------------------------------------------------

/// An empty box for spacing. Takes space in both directions.
Widget voxSpace(double size) => SizedBox(width: size, height: size);

/// An icon widget.
Widget voxIcon(IconData data, {double? size, Color? color}) =>
    Icon(data, size: size, color: color);

/// An image — auto-detects network URL vs asset path.
Widget voxImg(String source, {double? width, double? height, BoxFit? fit}) {
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return Image.network(source,
        width: width, height: height, fit: fit ?? BoxFit.cover);
  }
  return Image.asset(source,
      width: width, height: height, fit: fit ?? BoxFit.cover);
}

/// A loading spinner.
Widget voxLoader({double? size, Color? color}) {
  final indicator = CircularProgressIndicator(
    color: color,
    strokeWidth: 2.5,
  );
  if (size != null) {
    return SizedBox(width: size, height: size, child: indicator);
  }
  return indicator;
}

/// A horizontal divider line.
const Widget voxDivider = Divider();

/// Conditional rendering: shows [child] only when [condition] is true.
Widget voxWhen(bool condition, Widget child) {
  return condition ? child : const SizedBox.shrink();
}

/// Inverse conditional: shows [child] only when [condition] is false.
Widget voxWhenNot(bool condition, Widget child) {
  return condition ? const SizedBox.shrink() : child;
}

/// Toggle between two widgets based on a condition.
Widget voxToggle(bool condition, Widget onTrue, Widget onFalse) {
  return condition ? onTrue : onFalse;
}

// ---------------------------------------------------------------------------
// widget() — inline widget builder
// ---------------------------------------------------------------------------

/// Create a widget from a function — no class, no BuildContext.
///
/// ```dart
/// widget(() => label('Hello').bg(_kSurface).round(8))
/// final header = widget(() => row([logo, title]));
/// ```
Widget voxWidget(Widget Function() build) =>
    Builder(builder: (_) => build());

// ---------------------------------------------------------------------------
// progress() — horizontal progress bar
// ---------------------------------------------------------------------------

/// A horizontal progress bar (0.0–1.0). Null = indeterminate.
///
/// ```dart
/// progress(0.75, color: _kPurple, bg: _kSurface2, height: 6).round(4)
/// progress(null, color: _kPrimary)  // loading spinner style
/// ```
Widget voxProgress(
  double? value, {
  Color? color,
  Color? bg,
  double height = 4,
}) =>
    LinearProgressIndicator(
      value: value,
      valueColor:
          color != null ? AlwaysStoppedAnimation<Color>(color) : null,
      backgroundColor: bg,
      minHeight: height,
    );

// ---------------------------------------------------------------------------
// ring() — circular progress indicator
// ---------------------------------------------------------------------------

/// A circular progress indicator. Null value = spinning indefinitely.
///
/// ```dart
/// ring(0.6, size: 58, color: _kPurple, bg: _kSurface, width: 5)
/// ring(null, size: 24)  // loading spinner
/// ```
Widget voxRing(
  double? value, {
  double? size,
  Color? color,
  Color? bg,
  double width = 4,
}) {
  Widget w = CircularProgressIndicator(
    value: value,
    valueColor:
        color != null ? AlwaysStoppedAnimation<Color>(color) : null,
    backgroundColor: bg,
    strokeWidth: width,
    strokeCap: StrokeCap.round,
  );
  if (size != null) w = SizedBox(width: size, height: size, child: w);
  return w;
}

// ---------------------------------------------------------------------------
// fab() — FloatingActionButton
// ---------------------------------------------------------------------------

/// A floating action button. Pass [label] for an extended FAB.
///
/// ```dart
/// fab(Icons.add_rounded, () => go(AddScreen()), color: _kPrimary)
/// fab(Icons.add, () => submit(), label: 'New Post')
/// ```
Widget voxFab(
  IconData ico,
  VoidCallback onTap, {
  Color? color,
  Color? iconColor,
  String? label,
}) {
  if (label != null) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: color,
      foregroundColor: iconColor,
      icon: Icon(ico),
      label: Text(label),
    );
  }
  return FloatingActionButton(
    onPressed: onTap,
    backgroundColor: color,
    foregroundColor: iconColor,
    elevation: 0,
    child: Icon(ico),
  );
}

// ---------------------------------------------------------------------------
// switchTile() — toggle list tile
// ---------------------------------------------------------------------------

/// A list tile with a toggle switch.
///
/// ```dart
/// switchTile('Dark mode', isDark, (v) => vox.theme.toggle(),
///   subtitle: 'Toggle the app theme')
/// switchTile('Notifications', notifOn, (v) => setNotif(v))
/// ```
Widget voxSwitchTile(
  String label,
  bool value,
  void Function(bool) onChange, {
  String? subtitle,
  Color? activeColor,
  EdgeInsetsGeometry? padding,
}) =>
    SwitchListTile(
      contentPadding: padding,
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      activeThumbColor: activeColor,
      onChanged: onChange,
    );

// ---------------------------------------------------------------------------
// tile() — list tile
// ---------------------------------------------------------------------------

/// A single-row list item. Compose it with [card()] for full control.
///
/// ```dart
/// tile('Profile', leading: icon(Icons.person), onTap: () => go(ProfileScreen()))
/// tile('Logout', titleColor: _kDanger, onTap: logout)
/// tile(user.name, subtitle: user.email, trailing: icon(Icons.chevron_right))
/// ```
Widget voxTile(
  String title, {
  Widget? leading,
  String? subtitle,
  Widget? trailing,
  VoidCallback? onTap,
  Color? titleColor,
  FontWeight? titleWeight,
  TextDecoration? titleDecoration,
  Color? subtitleColor,
  EdgeInsetsGeometry? padding,
}) =>
    ListTile(
      contentPadding: padding,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: titleWeight,
          decoration: titleDecoration,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(color: subtitleColor, fontSize: 12))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
