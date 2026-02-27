import 'package:vox/vox.dart';

/// A simple counter app built with vox.
///
/// This demonstrates how vox eliminates Flutter boilerplate.
/// No StatefulWidget. No setState. No BuildContext.
/// Just your logic and your layout.
void main() => voxApp(
      title: 'Vox Counter',
      home: CounterScreen(),
    );

/// A counter screen — the vox way.
///
/// Compare this to a traditional Flutter StatefulWidget counter.
/// No State class. No initState. No setState.
/// Just `state()` for your data, and `view` for your layout.
class CounterScreen extends VoxScreen {
  /// Reactive state. That's it. One line.
  final count = state(0);

  @override
  get view => screen(
        'Counter',
        col([
          // Label reads `count` — auto-rebuilds when count changes.
          label('Tapped: ${count.val} times')
              .size(24).bold.center.expand,

          row([
            btn('−')
                .onTap(() => count.update((v) => v - 1))
                .expand,
            space(16),
            btn('+')
                .onTap(() => count.update((v) => v + 1))
                .expand,
          ]).pad(h: 32),
        ]).gap(24),
      );
}
