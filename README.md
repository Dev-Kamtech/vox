# vox

> One import. Full power. Write logic, not Flutter.

[![pub package](https://img.shields.io/pub/v/vox.svg)](https://pub.dev/packages/vox)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Vox is a Flutter framework that lets you write apps using clean, pseudo-code-like syntax. No boilerplate. No Flutter knowledge required. Just your logic, your layout, your styling.

## One Import

```dart
import 'package:vox/vox.dart';
```

That's it. State, UI, networking, navigation, storage, forms, animations, permissions, theming — all included.

## What It Looks Like

```dart
class TodoScreen extends VoxScreen {
  final todos = state<List>([]);
  final input = field();

  @override
  void ready() => fetch("https://api.com/todos") >> todos;

  @override
  get view => screen("Todos", [
    col([
      row([
        input,
        icon(Icons.add) >> () => todos << input.take(),
      ]).pad(16),
      todos.each((todo) => label(todo)).lazy,
    ]),
  ]);
}
```

No `StatefulWidget`. No `setState`. No `FutureBuilder`. No `jsonDecode`. No `TextEditingController`. Just logic.

## Philosophy

| Principle | What it means |
|-----------|---------------|
| Hide boilerplate, never hide behavior | You see what happens, never how Flutter does it |
| State is invisible | No providers, no streams, no notifiers |
| One import | Replaces dozens of package imports |
| Zero lock-in | Raw Flutter and any package works alongside vox |

## Features

- **State** — `state()`, `shared()`, `computed()`, `watch()`
- **UI** — `col()`, `row()`, `label()`, `btn()`, `icon()`, `.pad()`, `.expand`
- **Networking** — `fetch()`, `post()`, `>>` pipe operator
- **Navigation** — `go()`, `back()`, deep linking
- **Storage** — `save()`, `load()`, `stored()`, secure storage
- **Forms** — `field()`, `voxForm()`, built-in validation rules
- **Tabs** — `tabs()`, `topTabs()`, bottom navigation
- **Overlays** — `dialog()`, `sheet()`, `toast()`, `confirm()`
- **Theming** — `VoxTheme`, dark/light/system, runtime switching
- **Responsive** — `responsive(mobile:, tablet:, desktop:)`
- **Permissions** — `ask(Permission.camera)`
- **Realtime** — `connect()` WebSocket with auto-reconnect
- **Localization** — `t("hello")`, runtime locale switching
- **Animations** — `.animate(fade)`, `.hero("tag")`
- **And more** — clipboard, share, pickers, timers, logging, DI

## Getting Started

```yaml
dependencies:
  vox: ^0.1.0
```

```dart
import 'package:vox/vox.dart';

void main() => voxApp(home: HomeScreen());
```

## Documentation

See [DESIGN.md](DESIGN.md) for the full API reference and architecture.

## License

MIT
