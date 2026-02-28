# vox

> One import. Full power. Write logic, not Flutter.

[![pub package](https://img.shields.io/pub/v/vox.svg)](https://pub.dev/packages/vox)
[![pub points](https://img.shields.io/pub/points/vox)](https://pub.dev/packages/vox/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Vox is a Flutter framework that replaces boilerplate with clean, pseudo-code-like syntax. State, UI, networking, navigation, storage, forms, animations, theming, real-time — all from one import.

---

## Installation

```yaml
dependencies:
  vox: ^0.5.0
```

```dart
import 'package:vox/vox.dart';
```

---

## Quick Start — Counter App

```dart
import 'package:vox/vox.dart';

void main() => voxApp(title: 'Counter', home: CounterScreen());

class CounterScreen extends VoxScreen {
  final count = state(0);

  @override
  get view => screen(
    'Counter',
    col([
      label('Tapped: ${count.val} times').size(24).bold.center.expand,
      row([
        btn('−').onTap(() => count.update((v) => v - 1)).expand,
        space(16),
        btn('+').onTap(() => count.update((v) => v + 1)).expand,
      ]).pad(h: 32),
    ]).gap(24),
  );
}
```

The standard Flutter equivalent is ~60 lines. Vox: 18 lines.

---

## Core Features

### State

```dart
final count = state(0);             // reactive primitive
final todos = state<List>([]);      // reactive list

count.val                           // read (tracked — auto-rebuilds widget)
count.set(5)                        // set
count.update((v) => v + 1)         // transform

todos << item                       // append
todos.remove(item)                  // remove
todos.clear()                       // clear

final session = shared<Map>({});    // app-global state (cross-screen)
final full    = computed(() => '${first.val} ${last.val}'); // derived
```

### Layout

```dart
col([child1, child2]).gap(16)       // vertical layout
row([child1, child2]).between       // horizontal layout
screen('Title', body)               // Scaffold + AppBar
screen('Title', body,
  drawer: drawer([...]),            // with side drawer
  floatingActionButton: fab,        // with FAB
)
stack([bg, fg])                     // layered / overlay
scroll([child1, child2])            // scrollable column
grid(2, items, spacing: 8)          // grid layout
```

### Widgets

```dart
label('Hello').bold.size(24).color(Colors.purple)
btn('Save').onTap(save)
btn('Cancel').flat.onTap(back)
btn('Upload').outline.withIcon(Icons.upload)
icon(Icons.home).size(32)
img('https://example.com/photo.jpg')
space(16)
divider
loader()
when(isLoading, loader())
whenNot(isLoading, label('Done'))
toggle(isDark, darkWidget, lightWidget)
```

### Widget Extensions

```dart
widget.pad(all: 16)
widget.pad(h: 24, v: 8)
widget.padTop(8).padBottom(8)
widget.expand                       // Expanded
widget.center                       // Center
widget.bg(Colors.white)
widget.round(12)
widget.shadow()
widget.border(Colors.grey)
widget.w(200).h(100)
widget.tap(() {})
widget.onLong(() {})
widget.hide(condition)
widget.scroll                       // SingleChildScrollView
widget.animate(fade)                // fade-in on mount
widget.hero('tag')                  // Hero transition
```

### Networking

```dart
// GET — auto-parses JSON, pipes into state
fetch('https://api.com/todos') >> todos

// With loading + error
fetch('https://api.com/todos')
  .loading(isLoading)
  .onError((e) => toast('$e', type: VoxToastType.error))
  >> todos

// POST / PUT / DELETE
post('https://api.com/todos', body: {'title': 'Buy milk'}) >> response
put('https://api.com/todos/1', body: {'done': true})
delete('https://api.com/todos/1')

// Configure HTTP client once
configureHttp(
  baseUrl: 'https://api.com',
  headers: {'Authorization': 'Bearer $token'},
);
```

### Navigation

```dart
go(ProfileScreen())
go(AuthScreen(), replace: true)
back()
back(result: 'confirmed')
canBack                             // bool
```

### Storage

```dart
await save('token', 'abc123')
await load('token')                 // String?
await remove('token')

await saveSecure('pin', '1234')     // encrypted keychain / keystore
await loadSecure('pin')

final theme = stored('theme', 'dark'); // reactive + auto-persisted
theme.set('light')                     // updates AND saves to disk
```

### Forms & Validation

```dart
final email = field(hint: 'Email',    rules: [required, isEmail]);
final pass  = field(hint: 'Password', rules: [required, minLen(8)]);
final form  = voxForm({'email': email, 'pass': pass});

col([
  email.input,
  pass.input,
  btn('Login').onTap(() => form.submit(() {
    post('/login', body: form.values) >> user;
  })),
])

// Built-in rules: required, isEmail, isPhone, isNum,
// minLen(n), maxLen(n), match(field), custom((v) => ...)
```

### Tabs & Drawer

```dart
// Bottom navigation
tabs([
  tab('Home',    Icons.home,    HomeScreen()),
  tab('Profile', Icons.person,  ProfileScreen()),
])

// Top tab bar with AppBar
topTabs('Dashboard', [
  tab('All',    null, allContent),
  tab('Active', null, activeContent),
])

// Side drawer
screen('Home', body,
  drawer: drawer([
    navItem('Home',    Icons.home,    onTap: () => go(HomeScreen())),
    navItem('Settings',Icons.settings,onTap: () => go(SettingsScreen())),
  ]),
)
openDrawer();
closeDrawer();
```

### Animations

```dart
label('Hello').animate(fade)
label('Hello').animate(scale)
label('Hello').animate(slide.fromBottom)
label('Hello').animate(slide.fromRight).duration(400)

// Smooth value transition
anim(count.val, builder: (v) => label('${v.toInt()}'))
```

### Theming

```dart
void main() => voxApp(
  home: HomeScreen(),
  theme: VoxTheme(
    primary:    Color(0xFF6C63FF),
    background: Color(0xFFF5F5F5),
    surface:    Colors.white,
    text:       Color(0xFF1A1A2E),
    radius:     12,
    dark: VoxTheme.dark(),
  ),
);

// Toggle anywhere, no BuildContext:
vox.theme.toggle()
vox.theme.set(VoxTheme.dark())
```

### Real-Time WebSocket

```dart
final socket = ws('wss://chat.example.com/room/1');

socket.on('message', (data) => messages << data['text']);
socket.on('user_joined', (data) => log.info('${data["name"]} joined'));

socket.send({'type': 'chat', 'text': 'Hello!'});
socket.close();
```

### Localization

```dart
VoxLocale.configure({
  'en': {'greeting': 'Hello', 'welcome': 'Welcome, {name}!'},
  'fr': {'greeting': 'Bonjour', 'welcome': 'Bienvenue, {name} !'},
});
VoxLocale.set('fr');

label(t('greeting'))                    // 'Bonjour'
label(t('welcome', {'name': 'Marie'}))  // 'Bienvenue, Marie !'
```

### Permissions

```dart
final granted = await ask(VoxPermission.camera);
final hasLoc  = await check(VoxPermission.location);
await openPermissionSettings();
```

### Pickers

```dart
final date    = await pickDate();
final time    = await pickTime();
final country = await pickOne(['US', 'UK', 'CA'], label: (c) => c);
final tags    = await pickMany(['Dart', 'Flutter'], initial: ['Dart']);
```

### Overlays

```dart
toast('Saved!');
toast('Error!', type: VoxToastType.error);
toast('Warning', type: VoxToastType.warning);

await alert('Oops', message: 'Something went wrong.');
final ok = await confirm('Delete?', message: 'This cannot be undone.');
final v  = await sheet(() => label('Pick an option'));
```

### Dependency Injection

```dart
// Register at startup:
provide<AuthService>(AuthService());
provide<ApiClient>(ApiClient(baseUrl: env('API_URL')));

// Retrieve anywhere:
final auth = use<AuthService>();
final api  = use<ApiClient>();

// Testing — swap with mock:
provide<AuthService>(MockAuthService());
```

### Environment Config

```dart
VoxEnv.configure({
  'API_URL': const String.fromEnvironment('API_URL',
      defaultValue: 'https://api.example.com'),
});

final url = env('API_URL');
final key = env('KEY', fallback: 'default');
```

### Device & Platform

```dart
vox.isIOS        // bool
vox.isAndroid    // bool
vox.isWeb        // bool
vox.isMobile     // bool
vox.isDesktop    // bool
vox.device.name  // 'iPhone 15 Pro'
vox.device.os    // 'iOS 17.2'
```

### Share & Clipboard

```dart
await shareText('Check this out!');
await shareLink('https://example.com', subject: 'Cool site');
await shareFiles(['/path/to/photo.jpg']);

await copy('Copied text');
final text = await paste();
```

### Log & Timer

```dart
log.info('App started');
log.error('Something failed', error: e);
log.debug('Value: $count');

await delay(Duration(seconds: 2), () => toast('Done'));
every(Duration(seconds: 30), () => sync());
```

### Data Models

```dart
class User extends VoxModel {
  final String name;
  final String email;
  const User({required this.name, required this.email});

  @override
  User fromJson(Map<String, dynamic> json) =>
      User(name: json['name'], email: json['email']);

  @override
  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}

final user  = User().fromJson(json);
final users = User().listFromJson(jsonList);
```

### Testing

```dart
// test/counter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/testing.dart';
import 'package:vox/vox.dart';

void main() {
  voxTest('counter increments on tap', (tester) async {
    await tester.render(CounterScreen());

    tester.expect(label('Tapped: 0 times'), isVisible);
    await tester.tap(btn('+'));
    tester.expect(label('Tapped: 1 times'), isVisible);
  });
}
```

---

## Architecture

```
api/    ← syntax layer   (what you write)
core/   ← engine layer   (what vox does)
```

These layers never mix. New features are added as new modules — nothing existing ever breaks.

---

## Philosophy

| Principle | What it means |
|-----------|---------------|
| Hide boilerplate, never behavior | You see what happens, never how Flutter does it |
| State is invisible | No Provider, no ChangeNotifier, no StreamBuilder |
| Silent operations | Async, JSON, type coercion — handled inside vox |
| One import | Replaces dozens of package imports |
| Zero lock-in | Raw Flutter and any package works freely alongside |

---

## License

MIT — see [LICENSE](LICENSE)
