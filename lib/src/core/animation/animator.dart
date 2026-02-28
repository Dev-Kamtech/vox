import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Presets
// ---------------------------------------------------------------------------

/// Defines the animation properties a widget enters with.
///
/// Use the built-in presets:
/// - [fade] — opacity 0 → 1
/// - [scale] — scale 0.85 → 1 with fade
/// - [slide.fromBottom] / [slide.fromTop] / [slide.fromLeft] / [slide.fromRight]
class VoxAnimPreset {
  final Tween<double>? _opacity;
  final Tween<Offset>? _slide;
  final Tween<double>? _scale;
  final Curve _curve;

  VoxAnimPreset._({
    Tween<double>? opacity,
    Tween<Offset>? slide,
    Tween<double>? scale,
    Curve curve = Curves.easeOut,
  })  : _opacity = opacity,
        _slide = slide,
        _scale = scale,
        _curve = curve;
}

/// Fade-in animation — opacity 0 → 1.
final VoxAnimPreset fade = VoxAnimPreset._(
  opacity: Tween(begin: 0.0, end: 1.0),
);

/// Scale-up animation — scale 0.85 → 1 with fade.
final VoxAnimPreset scale = VoxAnimPreset._(
  scale: Tween(begin: 0.85, end: 1.0),
  opacity: Tween(begin: 0.0, end: 1.0),
);

/// Slide presets — [fromBottom], [fromTop], [fromLeft], [fromRight].
///
/// ```dart
/// label("Hello").animate(slide.fromBottom)
/// label("Hello").animate(slide.fromTop).duration(200)
/// ```
/// Slide animation preset container. Access via the [slide] constant.
const VoxSlide slide = VoxSlide();

/// Provides directional slide animation presets.
class VoxSlide {
  /// @nodoc
  const VoxSlide();

  VoxAnimPreset get fromBottom => VoxAnimPreset._(
        slide: Tween(begin: const Offset(0, 0.25), end: Offset.zero),
        opacity: Tween(begin: 0.0, end: 1.0),
      );

  VoxAnimPreset get fromTop => VoxAnimPreset._(
        slide: Tween(begin: const Offset(0, -0.25), end: Offset.zero),
        opacity: Tween(begin: 0.0, end: 1.0),
      );

  VoxAnimPreset get fromLeft => VoxAnimPreset._(
        slide: Tween(begin: const Offset(-0.25, 0), end: Offset.zero),
        opacity: Tween(begin: 0.0, end: 1.0),
      );

  VoxAnimPreset get fromRight => VoxAnimPreset._(
        slide: Tween(begin: const Offset(0.25, 0), end: Offset.zero),
        opacity: Tween(begin: 0.0, end: 1.0),
      );
}

// ---------------------------------------------------------------------------
// VoxAnimatedWidget
// ---------------------------------------------------------------------------

/// A widget that plays a one-shot enter animation on first mount.
///
/// Created via the `.animate()` extension on [Widget] — don't construct directly.
///
/// ```dart
/// label("Hello").animate(fade)
/// label("Hello").animate(slide.fromBottom).duration(200)
/// ```
class VoxAnimatedWidget extends StatefulWidget {
  /// The widget to animate.
  final Widget child;

  /// The animation preset to apply.
  final VoxAnimPreset preset;

  final Duration _duration;

  /// Create an animated widget.
  ///
  /// Prefer using the `.animate()` extension on [Widget] instead.
  // ignore: prefer_const_constructors_in_immutables
  VoxAnimatedWidget({
    required this.preset,
    Duration duration = const Duration(milliseconds: 350),
    super.key,
    required this.child,
  }) : _duration = duration;

  /// Return a copy with a custom duration in milliseconds.
  ///
  /// ```dart
  /// label("Hello").animate(fade).duration(200)
  /// ```
  VoxAnimatedWidget duration(int ms) => VoxAnimatedWidget(
        preset: preset,
        duration: Duration(milliseconds: ms),
        child: child,
      );

  @override
  State<VoxAnimatedWidget> createState() => _VoxAnimatedWidgetState();
}

class _VoxAnimatedWidgetState extends State<VoxAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  Animation<Offset>? _slide;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget._duration);
    final curved = CurvedAnimation(parent: _ctrl, curve: widget.preset._curve);

    _opacity = (widget.preset._opacity ?? Tween(begin: 1.0, end: 1.0))
        .animate(curved);

    if (widget.preset._slide != null) {
      _slide = widget.preset._slide!.animate(curved);
    }
    if (widget.preset._scale != null) {
      _scale = widget.preset._scale!.animate(curved);
    }

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FadeTransition(opacity: _opacity, child: widget.child);
    if (_slide != null) {
      child = SlideTransition(position: _slide!, child: child);
    }
    if (_scale != null) {
      child = ScaleTransition(scale: _scale!, child: child);
    }
    return child;
  }
}

// ---------------------------------------------------------------------------
// anim() — value-change animation
// ---------------------------------------------------------------------------

/// Animate a numeric value change. Rebuilds [builder] with a smoothly
/// interpolated value whenever [value] changes.
///
/// ```dart
/// anim(count.val, builder: (v) => label('$v'))
/// anim(progress.val, duration: Duration(milliseconds: 600), builder: (v) => ProgressBar(v))
/// ```
Widget anim<T extends num>(
  T value, {
  required Widget Function(T) builder,
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeOut,
}) =>
    TweenAnimationBuilder<T>(
      tween: Tween<T>(end: value),
      duration: duration,
      curve: curve,
      builder: (_, v, __) => builder(v),
    );
