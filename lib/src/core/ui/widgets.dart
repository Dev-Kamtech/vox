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

  /// Bold text.
  VoxLabel get bold => _copyWith(
      style: _style.copyWith(fontWeight: FontWeight.bold));

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
