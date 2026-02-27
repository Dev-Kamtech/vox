# vox_lint

Custom lint rules for the [vox](https://pub.dev/packages/vox) Flutter framework.
Catches anti-patterns and guides developers toward idiomatic vox code — all in the IDE, before you run anything.

---

## Setup

**1. Add to `dev_dependencies`:**

```yaml
dev_dependencies:
  custom_lint: ^0.6.0
  vox_lint: ^0.1.0
```

**2. Enable in `analysis_options.yaml`:**

```yaml
analyzer:
  plugins:
    - custom_lint
```

**3. Run `flutter pub get` and restart your IDE.**
Lint warnings will appear inline as you type.

---

## Rules

| Rule | Severity | What it catches |
|------|----------|----------------|
| `prefer_final_state` | ⚠️ warning | `state()` / `shared()` / `computed()` / `stored()` not declared `final` |
| `avoid_direct_navigator` | ⚠️ warning | `Navigator.of(context)` instead of vox `go()` / `back()` |
| `avoid_direct_snackbar` | ⚠️ warning | `ScaffoldMessenger.of(context)` instead of vox `toast()` |
| `prefer_vox_log` | ℹ️ info | `print()` / `debugPrint()` instead of vox `log.*` |
| `avoid_direct_theme` | ℹ️ info | `Theme.of(context)` instead of `vox.theme.*` |

---

## Rule Details

### `prefer_final_state`

vox reactive values must be `final`. Reassigning them would silently swap the reactive object, breaking all listeners.

```dart
// ❌ bad — count can be accidentally reassigned
var count = state(0);

// ✅ good
final count = state(0);
final total = computed(() => count.val * price.val);
final username = stored('username', '');
```

---

### `avoid_direct_navigator`

`Navigator.of(context)` requires a `BuildContext` and bypasses `VoxRouter`. Use vox's context-free navigation instead.

```dart
// ❌ bad
Navigator.of(context).push(MaterialPageRoute(builder: (_) => Detail()));
Navigator.of(context).pop();

// ✅ good
go(Detail());   // push
back();         // pop
```

---

### `avoid_direct_snackbar`

`ScaffoldMessenger.of(context)` requires a `BuildContext`. vox provides a context-free `toast()` with built-in styling.

```dart
// ❌ bad
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved!')));

// ✅ good
toast('Saved!');
toast('Error!', type: VoxToastType.error);
toast('Watch out', type: VoxToastType.warning);
```

---

### `prefer_vox_log`

`print()` and `debugPrint()` produce plain unstructured output. vox's `log` singleton has ANSI colors, log levels, and can be filtered or silenced.

```dart
// ❌ bad
print('User: $user');
debugPrint('Response: $json');

// ✅ good
log.info('User: $user');
log.debug('Response: $json');
log.warn('Rate limit approaching');
log.error('Auth failed: $e');
```

---

### `avoid_direct_theme`

`Theme.of(context)` couples widget code to `BuildContext` and doesn't react to `VoxThemeController` changes. Use `vox.theme.*` tokens instead.

```dart
// ❌ bad
final color = Theme.of(context).colorScheme.primary;

// ✅ good
final color = vox.theme.primary;
final isDark = vox.theme.dark;
```

---

## Disabling a Rule

Disable per-file in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - prefer_vox_log: false          # turn off project-wide
```

Or per-line with an ignore comment:

```dart
// ignore: prefer_vox_log
print('dev only — remove before shipping');
```
