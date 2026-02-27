/// Enter animations for widgets and value-change transitions.
///
/// ```dart
/// // Mount animations via .animate() extension on Widget:
/// label("Hello").animate(fade)
/// label("Hello").animate(slide.fromBottom)
/// label("Hello").animate(scale).duration(200)
///
/// // Animated value transitions:
/// anim(count.val, builder: (v) => label('Count: $v'))
/// anim(progress.val, duration: Duration(milliseconds: 500),
///     builder: (v) => LinearProgressIndicator(value: v / 100))
/// ```
library;

export '../core/animation/animator.dart'
    show VoxAnimPreset, VoxAnimatedWidget, VoxSlide, anim, fade, scale, slide;
