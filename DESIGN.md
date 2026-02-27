# VOX — Design Document

> One import. Full power. Write logic, not Flutter.

---

## Philosophy

| Principle | What it means |
|-----------|---------------|
| Hide boilerplate, never hide behavior | Developers see what happens, never how Flutter does it |
| State is invisible | No StatefulWidget, no setState, no streams, no providers |
| Silent operations | Async, JSON parsing, type coercion — all handled silently |
| One import | `import 'package:vox/vox.dart';` replaces everything |
| Zero lock-in | Raw Flutter, any package, any pattern works freely alongside |
| Pseudo-code feel | Write logic. Not English. Not Dart boilerplate. |

---

## Architecture Law — The Two Layers

```
api/    ← the syntax layer   (what developers write)
core/   ← the engine layer   (what vox does internally)
```

**These two layers never mix internals. They only communicate through clean interfaces.**

| If we want to... | We touch... | We don't touch... |
|---|---|---|
| Change the syntax | `api/` only | `core/` untouched |
| Swap HTTP engine | `core/net/` only | `api/net.dart` untouched |
| Change state engine | `core/reactive/` only | Everything else untouched |
| Add a new feature | New module in `core/` + new file in `api/` | Nothing existing breaks |

State management lives in `core/reactive/` only. The developer never sees it, never picks it, never configures it. `state()` is just a function call. What happens underneath is vox's problem.

---

## Error Philosophy

**All errors must come from the developer using the package. Never from the package itself.**

- The package is internally bulletproof — all edge cases handled silently inside `core/`
- At the `api/` boundary: validate all inputs. If wrong usage → throw a `VoxError` that describes what the developer did wrong, in vox terms — never exposing Flutter/Dart internals
- In production: graceful degradation. Vox never crashes the app due to an internal failure
- In debug mode: assert with clear messages like:
  `"vox: todos.each() received null — make sure todos is initialized with state([])"`
- Error messages speak vox language, not Flutter language. Developer never sees a Flutter stack trace caused by vox internals

```
Developer writes code
     ↓
api/ layer validates → VoxError if misused (developer's fault, clear message in vox terms)
     ↓
core/ layer executes → wrapped defensively (vox's responsibility, never leaks out)
     ↓
Result returned cleanly
```

---

## The One Import

```dart
import 'package:vox/vox.dart';
```

That's it. Done. HTTP, state, navigation, storage, forms, validation, animation — all in.

---

## Syntax Vision

The syntax reads like structured logic. Not English. Not Flutter. Just intent.

```dart
class TodoScreen extends VoxScreen {
  final todos  = state<List>([]);
  final input  = field();

  @override
  void ready() => fetch("https://api.com/todos") >> todos;

  @override
  get view => screen("Todos", [
    col([
      row([
        input,
        icon(Icons.add) >> () => todos << input.take(),
      ]).pad(16),
      todos.each((todo) => label(todo)).col.expand,
    ]),
  ]);
}
```

### Operator Meanings

| Operator | Meaning | Example |
|----------|---------|---------|
| `>>` | pipe / bind output to target | `fetch(url) >> todos` |
| `<<` | push / append into state | `todos << newItem` |
| `=>` | map / transform | `todos.each((t) => label(t))` |

---

## Core API Surface

### Screen

```dart
class MyScreen extends VoxScreen {
  // state — reactive, auto-rebuilds on change
  final count = state(0);

  // field — form input controller
  final name  = field();

  // lifecycle hooks (all optional)
  @override void ready()   {}  // on mount
  @override void dispose() {}  // on unmount

  // the view — no BuildContext, no Widget tree ceremony
  @override
  get view => screen("Title", [ /* children */ ]);
}
```

### State

```dart
final count  = state(0);          // reactive int
final todos  = state<List>([]);   // reactive list
final user   = state<Map>({});    // reactive map
final active = state(false);      // reactive bool

count.val                  // read value
count.set(5)               // set value
count.update((v) => v + 1) // transform

todos << item              // append to list
todos.remove(item)         // remove from list
todos.clear()              // clear list
todos.val                  // raw list value
```

### Field (Form Input)

```dart
final email = field();        // text field, empty
final age   = field(type: num);

email.take()    // get value AND clear
email.val       // get value, keep
email.clear()   // clear
email.focus()   // focus programmatically
email.error     // current validation error
```

### Layout Primitives

```dart
// Vertical layout
col([ child1, child2 ])

// Horizontal layout
row([ child1, child2 ])

// Stack / overlay
stack([ child1, child2 ])

// Screen wrapper (Scaffold)
screen("Title", [ child ])

// Scrollable
scroll([ child ])

// Grid
grid(2, [ child1, child2 ])  // 2-column grid
```

### Widget Shortcuts

```dart
label("hello")              // Text
label("hello").bold         // Text bold
label("hello").size(24)     // Font size

icon(Icons.add)             // Icon
icon(Icons.add).size(32)    // Icon size

btn("Save", onTap: () {})   // ElevatedButton
btn("Cancel").outline       // OutlinedButton
btn("Link").flat            // TextButton

img("https://...")          // Network image
img("assets/logo.png")      // Asset image

divider                     // Divider
space(16)                   // SizedBox gap
loader()                    // CircularProgressIndicator

field()                     // TextField
field(hint: "Email")        // TextField with hint

when(condition, widget)     // conditional render
whenNot(condition, widget)  // inverse conditional
```

### Widget Extensions (chainable on anything)

```dart
widget.pad(16)              // EdgeInsets.all(16)
widget.pad(h: 16, v: 8)    // horizontal + vertical
widget.padTop(8)
widget.padBottom(8)

widget.expand               // Expanded(child: widget)
widget.center               // Center(child: widget)
widget.scroll               // SingleChildScrollView
widget.hide(condition)      // Visibility

widget.bg(Colors.blue)      // Container background color
widget.round(12)            // BorderRadius
widget.shadow()             // BoxShadow
widget.border(Colors.grey)  // Border

widget.w(200)               // SizedBox width
widget.h(100)               // SizedBox height
widget.size(200, 100)       // width + height

widget.tap(() {})           // GestureDetector onTap
widget.onLong(() {})        // onLongPress

// Text-specific
label("hi").bold
label("hi").italic
label("hi").size(24)
label("hi").color(Colors.red)
label("hi").align(center)
```

### Networking

```dart
// GET
fetch("https://api.com/todos") >> todos       // load into state silently
fetch("https://api.com/todos")                // returns Future<dynamic>

// POST
post("https://api.com/todos", body: { "title": "buy milk" }) >> response

// With loading state
fetch("https://api.com/todos")
  .loading(isLoading)   // sets state<bool> during fetch
  .onError((e) => {})   // optional error handler
  >> todos

// Access parsed JSON directly — no manual parsing
final data = await fetch("https://api.com/user");
// data is already Map / List — no jsonDecode needed
```

### Navigation

```dart
go(OtherScreen())           // push
go(OtherScreen(), replace: true) // replace current
back()                      // pop
back(result: "done")        // pop with result

// Pass data
go(DetailScreen(id: item.id))

// Named routes (optional)
route("/todos", TodoScreen())
route("/profile", ProfileScreen())
```

### Storage

```dart
// Key-value (persisted)
save("token", "abc123")
load("token")                   // returns String?
remove("token")

// Reactive saved state — persists across restarts
final theme = stored("theme", "dark");   // state + persisted
theme.val                                // "dark"
theme.set("light")                       // updates + saves

// Secure storage
saveSecure("password", value)
loadSecure("password")
```

### Forms & Validation

```dart
final form = voxForm({
  "email": field(rules: [required, isEmail]),
  "pass":  field(rules: [required, minLen(8)]),
});

form.submit(() {
  // only called if all fields valid
  post("/login", body: form.values) >> user;
});

// Individual field validation
final email = field(rules: [required, isEmail]);

// Built-in rules
required        // not empty
isEmail         // valid email format
isPhone         // valid phone
minLen(n)       // minimum length
maxLen(n)       // maximum length
isNum           // numeric only
match(field)    // matches another field (confirm password)
custom((v) => v.startsWith("A") ? null : "Must start with A")
```

### Animations

```dart
// Animate any widget
label("Hello").animate(fade)          // fade in on mount
label("Hello").animate(slide.fromBottom)
label("Hello").animate(scale)

// Transition between states
anim(count.val, builder: (v) => label("$v"))

// Duration chaining
label("Hello").animate(fade).duration(300)
```

---

## State Reactivity Model

State is fully hidden. When a `state()` value changes, only widgets that used it rebuild. The developer never calls `setState`, never wraps in `StreamBuilder`, never touches `ChangeNotifier`.

```dart
final count = state(0);

// This widget auto-rebuilds when count changes
label("${count.val}")     // no StreamBuilder, no watch(), nothing

// This triggers a rebuild everywhere count.val is used
btn("Add", onTap: () => count.update((v) => v + 1))
```

Internally: signal-based reactivity (similar to SolidJS signals), tracked at the widget level through `VoxScreen`'s build cycle.

---

## File Structure (Package)

```
vox/
├── lib/
│   ├── vox.dart                    ← the one import (barrel export)
│   └── src/
│       ├── core/
│       │   ├── vox_screen.dart     ← VoxScreen base class
│       │   ├── state.dart          ← state<T>(), VoxState
│       │   ├── field.dart          ← field(), VoxField
│       │   └── context.dart        ← VoxContext (internal)
│       ├── ui/
│       │   ├── layout.dart         ← col, row, stack, screen, scroll, grid
│       │   ├── widgets.dart        ← label, icon, btn, img, divider, loader
│       │   ├── extensions.dart     ← .pad, .expand, .center, .bg, .round...
│       │   └── conditional.dart    ← when, whenNot
│       ├── net/
│       │   ├── fetch.dart          ← fetch(), post(), put(), delete()
│       │   └── pipe.dart           ← >> operator binding
│       ├── nav/
│       │   └── navigation.dart     ← go(), back(), route()
│       ├── storage/
│       │   ├── local.dart          ← save(), load(), remove()
│       │   ├── secure.dart         ← saveSecure(), loadSecure()
│       │   └── stored.dart         ← stored() reactive persisted state
│       ├── forms/
│       │   ├── form.dart           ← voxForm()
│       │   └── rules.dart          ← required, isEmail, minLen...
│       └── animation/
│           └── animate.dart        ← .animate(), fade, slide, scale
├── example/
│   └── lib/
│       └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

---

## App Entry Point

Every vox app starts with one call. No `MaterialApp`, no `runApp`, no `WidgetsFlutterBinding`:

```dart
void main() => voxApp(
  home: TodoScreen(),
);

// With optional config
void main() => voxApp(
  home: TodoScreen(),
  title: "My App",
  theme: dark,        // or light, or custom
  routes: {
    "/todos":   TodoScreen(),
    "/profile": ProfileScreen(),
  },
);
```

`voxApp()` handles `runApp`, `MaterialApp`, binding initialization, navigation setup — all silently.

---

## Reactivity Granularity

Rebuilds happen at the **widget level**, not the screen level.

```dart
class CounterScreen extends VoxScreen {
  final count = state(0);
  final name  = state("vox");

  @override
  get view => screen("Counter", [
    label("${count.val}"),   // ← only THIS rebuilds when count changes
    label("${name.val}"),    // ← only THIS rebuilds when name changes
    btn("Add", onTap: () => count.update((v) => v + 1)),  // never rebuilds
  ]);
}
```

No `setState` rebuilding the entire screen. Signal-based tracking — only the exact widget that read a state value rebuilds when it changes. This is the performance model.

---

## Debug vs Production Behavior

| Situation | Debug mode | Production mode |
|-----------|------------|-----------------|
| Developer misused API | `VoxError` thrown, full message in vox language | Same — this is always the developer's fault |
| Internal vox failure | Assert + detailed message | Fail silently, degrade gracefully |
| Network error (unhandled) | Clear VoxError pointing to missing `.onError()` | Silent fallback, state stays as-is |
| Null state accessed | Assert: `"vox: count.val accessed before state() init"` | Returns safe default |
| Unknown route | Assert: `"vox: go() called with unregistered screen"` | No-op navigation |

---

## Platform-Aware Silent Handling

Vox detects the platform and swaps implementations silently. Developer writes the same code everywhere.

| Feature | Mobile | Web |
|---------|--------|-----|
| Secure storage | Keychain / Keystore | Encrypted localStorage |
| Local storage | SharedPreferences | localStorage |
| Image loading | Cached network image | Standard network image |
| Navigation | Stack navigator | Browser history-aware |
| File picking | Native picker | Browser file input |

Developer writes `saveSecure("token", value)` on all platforms. What happens underneath is vox's problem.

---

## State List Operations

State lists (`state<List>`) come with built-in operations:

```dart
final todos = state<List>([]);

todos << item                          // append
todos.remove(item)                     // remove
todos.clear()                          // clear
todos.val                              // raw list

todos.each((t) => label(t))           // map to widgets
todos.where((t) => t.done)            // filter
todos.search("q", by: (t) => t.title) // search
todos.sort(by: (t) => t.date)         // sort
todos.paginate(20)                     // paginate (20 per page)
todos.first                            // first item state
todos.isEmpty                          // bool state
todos.length                           // int state
```

All of these are reactive — any widget reading them auto-rebuilds when they change.

---

## Versioning Strategy

Follows strict SemVer with a vox-specific meaning:

| Version bump | Means |
|---|---|
| **Major** (2.0.0) | Syntax change — `api/` layer changed. Developer may need to update their code. |
| **Minor** (1.1.0) | New feature added — new module. Zero breaking changes. |
| **Patch** (1.0.1) | Engine fix — `core/` internals changed. Developer notices nothing. |

This means a developer can upgrade patches and minors blindly. Only major versions require attention — and we'll provide migration guides.

---

## Testing

Vox provides a `VoxTest` helper so developers can test their screens without Flutter test setup knowledge:

```dart
void main() {
  voxTest("TodoScreen adds item", (tester) async {
    await tester.render(TodoScreen());

    tester.find(input).type("Buy milk");
    tester.find(icon(Icons.add)).tap();

    tester.expect(todos, hasLength(1));
    tester.expect(label("Buy milk"), isVisible);
  });
}
```

Internally wraps `flutter_test` — developer never imports it.

---

## Build Phases

| Phase | What | Status |
|-------|------|--------|
| 1 | Syntax & API Design | ✅ This document |
| 2 | Package structure | ⬜ Next |
| 3 | UI Layer (layout + widgets + extensions) | ⬜ |
| 4 | State (reactive, hidden, signal-based) | ⬜ |
| 5 | Networking (fetch, post, >> operator) | ⬜ |
| 6 | Storage (local + secure + stored) | ⬜ |
| 7 | Navigation | ⬜ |
| 8 | Forms & Validation | ⬜ |
| 9 | Animations | ⬜ |
| 10 | pub.dev publishing prep | ⬜ |

---

## Global / Shared State

Screen-local state is declared inside `VoxScreen`. But real apps need state that lives across screens — user session, cart, app settings, auth token. This is **global state**.

```dart
// Declared OUTSIDE any screen — lives for the app's lifetime
final session = shared<Map>({});        // shared state
final cart    = shared<List>([]);       // shared list
final theme   = shared("dark");         // shared value

// Used inside ANY screen — reactive, auto-rebuilds that screen
class CartScreen extends VoxScreen {
  @override
  get view => screen("Cart", [
    cart.each((item) => label(item.name)).col,
    label("Total: ${cart.length}"),
  ]);
}

class ProductScreen extends VoxScreen {
  @override
  get view => screen("Product", [
    btn("Add to Cart") >> () => cart << product,
  ]);
}
```

`shared()` vs `state()`:
- `state()` → lives inside a screen, dies when screen is disposed
- `shared()` → lives for the app lifetime, accessible from anywhere

Internally stored in a global registry inside `core/reactive/`. Developer never sees this.

---

## VoxWidget — Reusable Components

Not everything is a full screen. Developers need reusable sub-components with their own local state.

```dart
// A reusable component — NOT a full screen
class TodoItem extends VoxWidget {
  final String title;
  final bool done;

  TodoItem({ required this.title, required this.done });

  final expanded = state(false);   // local state, lives with this widget

  @override
  get view => col([
    row([
      label(title).expand,
      icon(expanded.val ? Icons.expand_less : Icons.expand_more)
        >> () => expanded.update((v) => !v),
    ]).pad(12),
    when(expanded.val, label("Details...").pad(h: 12, v: 8)),
  ]).round(8).bg(Colors.white).shadow();
}

// Used inside any screen or any other VoxWidget
class TodoScreen extends VoxScreen {
  final todos = state<List>([]);

  @override
  get view => screen("Todos", [
    todos.each((t) => TodoItem(title: t.title, done: t.done)).col,
  ]);
}
```

`VoxWidget` vs `VoxScreen`:
- `VoxScreen` → full screen with Scaffold, AppBar, navigation aware
- `VoxWidget` → reusable piece, no Scaffold, can be used anywhere, has its own local state

---

## Computed / Derived State

State that automatically derives its value from other state. Reactive — updates the moment its sources change.

```dart
final first  = state("John");
final last   = state("Doe");

// Auto-updates when first or last changes
final full   = computed(() => "${first.val} ${last.val}");

// Complex derivations
final todos      = state<List>([]);
final showDone   = state(false);
final filtered   = computed(() =>
  showDone.val ? todos.val : todos.val.where((t) => !t.done).toList()
);

// Used exactly like state
label(full.val)                         // auto-rebuilds when full changes
filtered.each((t) => label(t.title))   // auto-rebuilds when filter changes
```

`computed()` is read-only. You cannot `.set()` it — it always derives from its sources.

---

## Side Effects — `watch()`

Run code when state changes. No widget rebuild involved — pure logic reaction.

```dart
class AuthScreen extends VoxScreen {
  final user = shared<Map?>({});

  @override
  void ready() {
    // When user logs in, navigate away
    watch(user, (value) {
      if (value != null) go(HomeScreen(), replace: true);
    });

    // Watch multiple
    watch(cart, (items) => save("cart", items));   // auto-save cart
  }
}
```

Common use cases:
- Navigate when auth state changes
- Auto-save state to storage when it changes
- Trigger a fetch when a filter state changes
- Log analytics when a value changes

`watch()` is registered in `ready()` and auto-disposed when the screen is disposed.

---

## Full Screen Lifecycle

Screens have more lifecycle moments than just mount/unmount.

```dart
class VideoScreen extends VoxScreen {
  @override
  void ready() {}         // screen mounted for first time

  @override
  void resume() {}        // came back into view (popped back to from another screen)

  @override
  void pause() {}         // another screen pushed on top (still alive, not visible)

  @override
  void background() {}    // app went to background (home button pressed)

  @override
  void foreground() {}    // app came back from background

  @override
  void dispose() {}       // screen fully removed from stack
}
```

All hooks are optional. Developer implements only what they need.

Use cases:
- `resume()` → refresh data, restart animation, resume video
- `pause()` → pause video, stop timer
- `background()` → save draft, pause music
- `foreground()` → check for new notifications, re-auth if needed

---

## Theming

Not a design system. Just a clean way to define and access app-wide visual tokens.

```dart
// In voxApp — define once
void main() => voxApp(
  home: HomeScreen(),
  theme: VoxTheme(
    primary:    Color(0xFF6C63FF),
    background: Color(0xFFF5F5F5),
    surface:    Colors.white,
    text:       Color(0xFF1A1A2E),
    radius:     12.0,
    // Automatic dark mode variant
    dark: VoxTheme(
      primary:    Color(0xFF6C63FF),
      background: Color(0xFF1A1A2E),
      surface:    Color(0xFF2A2A3E),
      text:       Colors.white,
    ),
  ),
);

// Inside any screen or VoxWidget — access via vox.theme
label("Hello").color(vox.theme.text)
btn("Save").bg(vox.theme.primary)
col([]).bg(vox.theme.background)

// Built-in presets
theme: VoxTheme.dark()
theme: VoxTheme.light()
theme: VoxTheme.system()   // follows device dark/light setting
```

Theme switching at runtime:
```dart
vox.theme.toggle()              // switch dark ↔ light
vox.theme.set(VoxTheme.dark())  // set explicitly
```

---

## Responsive Layout

One codebase, every screen size. No MediaQuery. No LayoutBuilder.

```dart
// Swap layout based on screen size
responsive(
  mobile:  col([ header, content ]),
  tablet:  row([ header.w(300), content.expand ]),
  desktop: row([ sidebar.w(250), content.expand, panel.w(300) ]),
)

// Breakpoint values (customizable in voxApp)
// mobile:  < 600px
// tablet:  600px – 1200px
// desktop: > 1200px

// Access current screen dimensions
vox.screen.width
vox.screen.height
vox.screen.isMobile
vox.screen.isTablet
vox.screen.isDesktop

// Conditional value (not layout)
label("Hello").size(vox.screen.isMobile ? 14 : 18)
```

Customize breakpoints in `voxApp`:
```dart
voxApp(
  home: HomeScreen(),
  breakpoints: VoxBreakpoints(mobile: 480, tablet: 1024),
)
```

---

## Permissions

Common in mobile apps. One call, silent handling.

```dart
// Request permission
final granted = await ask(Permission.camera);

// Check without requesting
final hasLocation = await check(Permission.location);

// Built-in permissions
Permission.camera
Permission.microphone
Permission.location
Permission.locationAlways    // background location
Permission.notifications
Permission.storage
Permission.contacts
Permission.photos

// Usage in screen
class ScanScreen extends VoxScreen {
  @override
  void ready() async {
    final ok = await ask(Permission.camera);
    if (!ok) back();   // no camera access — go back
  }
}
```

---

## Device & Platform Info

```dart
// Platform
vox.isWeb
vox.isAndroid
vox.isIOS
vox.isMacOS
vox.isWindows
vox.isLinux
vox.isMobile      // android || ios
vox.isDesktop     // macos || windows || linux

// Device
vox.device.name   // "iPhone 15 Pro"
vox.device.os     // "iOS 17.2"
```

---

## Platform Implementation Strategy

Dart uses conditional imports for platform-specific code. Every module that has platform differences follows this pattern internally:

```
core/storage/
  storage.dart          ← abstract interface (what api/ calls)
  storage_io.dart       ← mobile/desktop implementation
  storage_web.dart      ← web implementation

core/permissions/
  permissions.dart      ← abstract interface
  permissions_io.dart   ← mobile implementation
  permissions_web.dart  ← web stub (most permissions N/A)
```

Developer sees zero of this. `save("key", val)` works identically on all platforms.

---

## pub.dev Requirements (Phase 2 must-haves)

For a high pub.dev score and discoverability, Phase 2 must include:

| File | Purpose |
|------|---------|
| `LICENSE` | MIT license — required for pub.dev |
| `README.md` | Rewritten with pub.dev badges, quick-start, full examples |
| `CHANGELOG.md` | Formatted per pub.dev convention |
| `pubspec.yaml` | `description` under 180 chars, `homepage`, `repository`, `issue_tracker` |
| `example/lib/main.dart` | Working example app (pub.dev shows this) |
| Dartdoc comments | Every public API must have `///` comments for pub.dev API docs |

pub.dev scoring factors (we target 130/130):
- Has example: ✅
- Has description: ✅
- Follows Dart conventions: ✅
- Passes `dart analyze`: ✅
- Passes `dart format`: ✅
- Has license: ✅
- Supports multiple platforms: ✅

---

## Dialogs, Modals, and Bottom Sheets

Every app needs confirmation dialogs, option pickers, bottom sheets.

```dart
// Alert
dialog("Delete?", "This cannot be undone.", actions: [
  btn("Cancel") >> () => close(),
  btn("Delete").destructive >> () { deleteItem(); close(); },
]);

// Bottom sheet
sheet([
  label("Share via").bold,
  btn("Email") >> () => shareViaEmail(),
  btn("Link")  >> () => copyLink(),
]);

// Full modal screen
modal(EditProfileScreen());

// Confirmation shorthand (returns bool)
final yes = await confirm("Delete this item?");
```

---

## Toasts and Snackbars

Transient feedback messages.

```dart
toast("Saved successfully");
toast("No internet", type: error);
toast("Item deleted", action: btn("Undo") >> () => restore());

// Typed variants
toast.success("Done!");
toast.error("Failed to load");
toast.warning("Low storage");
toast.info("Update available");
```

---

## Tabs and Bottom Navigation

Standard multi-tab app shells.

```dart
// Bottom navigation
class HomeShell extends VoxScreen {
  @override
  get view => tabs([
    tab("Home",    Icons.home,    HomeScreen()),
    tab("Search",  Icons.search,  SearchScreen()),
    tab("Profile", Icons.person,  ProfileScreen()),
  ]);
}

// Top tab bar inside a screen
class OrdersScreen extends VoxScreen {
  @override
  get view => screen("Orders", [
    topTabs([
      tab("Active",    ActiveOrders()),
      tab("Completed", CompletedOrders()),
    ]).expand,
  ]);
}
```

---

## Drawers and Side Navigation

```dart
class HomeScreen extends VoxScreen {
  @override
  get view => screen("Home", [
    content,
  ], drawer: drawer([
    label("Menu").bold.pad(16),
    navItem("Settings", Icons.settings) >> () => go(SettingsScreen()),
    navItem("Logout",   Icons.logout)   >> () => logout(),
  ]));
}

// Programmatic
openDrawer();
closeDrawer();
```

---

## Lazy Lists, Infinite Scroll, and Paginated Loading

Without lazy lists, anything over ~50 items will lag. This is critical for performance.

```dart
// Lazy list (uses ListView.builder internally — items built on demand)
todos.each((t) => TodoItem(t)).lazy

// Infinite scroll with auto-fetch
todos.each((t) => TodoItem(t)).lazy.onEnd(() {
  fetchMore("api.com/todos?page=${page.val}") >> todos.append;
})

// Loading footer
todos.each((t) => TodoItem(t)).lazy.onEnd(loadMore).loadingFooter(loader())

// Separator between items
todos.each((t) => TodoItem(t)).lazy.separated(divider)

// Grid lazy
todos.each((t) => TodoItem(t)).lazyGrid(2)
```

**Key distinction:** `.each()` = builds all items eagerly (Column). `.each().lazy` = builds on demand (ListView.builder).

---

## Pull-to-Refresh

```dart
// On any lazy list
todos.each((t) => TodoItem(t)).lazy.refresh(() async {
  fetch("api.com/todos") >> todos;
})

// Standalone
refreshable(
  onRefresh: () => fetch("api.com/data") >> data,
  child: col([...]),
)
```

---

## Swipe Actions

```dart
todos.each((t) => TodoItem(t)
  .swipe(
    left:  action("Delete",  Icons.delete,  Colors.red)  >> () => todos.remove(t),
    right: action("Archive", Icons.archive, Colors.blue) >> () => archive(t),
  )
).lazy
```

---

## Loading / Error / Empty State Pattern

The most repeated boilerplate in Flutter. Vox eliminates it completely.

```dart
// Declarative state rendering
todos.view(
  loading: () => loader(),
  empty:   () => label("No todos yet"),
  error:   (e) => label("Failed: $e"),
  data:    (items) => items.each((t) => TodoItem(t)).lazy,
)

// Shorthand with defaults
todos.each((t) => TodoItem(t)).withStates(
  loading: loader(),
  empty: label("Nothing here"),
)
```

---

## Layout Alignment and Gaps

`col()` and `row()` need alignment, spacing, and flex weights.

```dart
col([a, b, c]).gap(12)               // space between children
col([a, b, c]).align(center)         // mainAxisAlignment: center
col([a, b, c]).cross(stretch)        // crossAxisAlignment: stretch
col([a, b, c]).between               // spaceBetween
col([a, b, c]).around                // spaceAround
col([a, b, c]).evenly                // spaceEvenly

row([a.flex(2), b.flex(1)])          // flex weights
```

---

## Dependency Injection

Swap services, configure per environment, override for testing.

```dart
// Register
provide<AuthService>(AuthService());
provide<ApiClient>(ApiClient(baseUrl: env("API_URL")));

// Use in any screen
final auth = use<AuthService>();
final api  = use<ApiClient>();

// Override for testing
voxTest("login test", (tester) async {
  override<AuthService>(MockAuthService());
  await tester.render(LoginScreen());
});
```

---

## Environment Configuration

```dart
void main() => voxApp(
  home: HomeScreen(),
  env: VoxEnv(
    baseUrl: String.fromEnvironment('BASE_URL', defaultValue: 'https://dev.api.com'),
  ),
);

// Access anywhere
env("baseUrl")
fetch("${env('baseUrl')}/todos") >> todos;
```

---

## Network Interceptors and Middleware

Auth tokens, refresh logic, retries, logging — all built in.

```dart
voxApp(
  home: HomeScreen(),
  net: VoxNet(
    baseUrl: "https://api.com",
    headers: { "Accept": "application/json" },
    interceptors: [
      authToken(() => loadSecure("token")),
      refreshToken(
        onRefresh: () => post("/refresh", body: { "token": load("refresh") }),
        onFail: () => go(LoginScreen(), replace: true),
      ),
      retry(maxAttempts: 3),
      logger(),
    ],
  ),
);
```

---

## Deep Linking and URL Parameters

```dart
voxApp(
  home: HomeScreen(),
  routes: {
    "/":              HomeScreen(),
    "/todos":         TodoScreen(),
    "/todos/:id":     (params) => TodoDetailScreen(id: params["id"]),
    "/profile":       ProfileScreen(),
  },
  onDeepLink: (uri) => goNamed(uri.path),
);

// Navigate by name
goNamed("/todos/42");
goNamed("/profile", query: { "tab": "settings" });
```

---

## App Initialization and Splash

Async startup with splash screen.

```dart
void main() => voxApp(
  home: HomeScreen(),
  splash: SplashScreen(),
  init: () async {
    await initStorage();
    final token = await loadSecure("token");
    if (token != null) fetch("api.com/me", headers: auth(token)) >> currentUser;
  },
  onReady: () {
    if (currentUser.val != null) go(HomeScreen(), replace: true);
    else go(LoginScreen(), replace: true);
  },
);
```

---

## Localization / i18n

```dart
voxApp(
  home: HomeScreen(),
  locale: VoxLocale(
    defaultLocale: "en",
    translations: {
      "en": { "hello": "Hello", "welcome": "Welcome, {name}" },
      "ar": { "hello": "اهلا",  "welcome": "اهلا، {name}" },
    },
  ),
);

// Use
label(t("hello"))
label(t("welcome", args: { "name": user.val["name"] }))

// Switch at runtime
vox.locale.set("ar");
vox.locale.current   // "ar"
```

---

## Offline Support and Connectivity

```dart
// Cache-first
fetch("api.com/todos").cache(duration: 5.minutes) >> todos

// Stale-while-revalidate
fetch("api.com/todos").stale() >> todos

// Connectivity state (reactive)
vox.isOnline
vox.isOffline

watch(vox.isOnline, (online) {
  if (online) syncPendingChanges();
});
```

---

## WebSocket / Realtime

```dart
final socket = connect("wss://api.com/ws");

socket.on("message", (data) => messages << data);
socket.send("message", { "text": "hello" });
socket.close();

// Auto-reconnect
final socket = connect("wss://api.com/ws", reconnect: true);
```

---

## Logging

```dart
log("User logged in");
log.warn("Token expiring soon");
log.error("Failed to load", error: e);
log.debug("Response: $data");

// Configure level
voxApp(home: HomeScreen(), logLevel: LogLevel.warn);
```

---

## Crash Reporting Hooks

```dart
voxApp(
  home: HomeScreen(),
  onError: (error, stack) => Sentry.captureException(error, stackTrace: stack),
  onNetError: (url, statusCode, body) => analytics.trackNetworkError(url, statusCode),
);
```

---

## Type-Safe Models

```dart
// Developer defines model
class Todo {
  final String title;
  final bool done;
  Todo({ required this.title, required this.done });
  factory Todo.fromMap(Map m) => Todo(title: m["title"], done: m["done"]);
}

// Fetch with type mapping
fetch("api.com/todos").as<Todo>((m) => Todo.fromMap(m)) >> todos;

// Manual mapping still works
fetch("api.com/todos").map((json) => Todo.fromJson(json)) >> todos;
```

---

## Accessibility

```dart
// Semantic labels for screen readers
icon(Icons.add).semantic("Add new todo")
img("photo.jpg").semantic("Profile photo of John")

// Announce dynamic changes
announce("Item deleted")

// All vox widgets auto-include:
// - Semantics wrappers
// - Minimum 48x48 touch targets by default
// - Proper focus ordering
```

---

## Keyboard and Focus

```dart
// Keyboard shortcuts (web/desktop)
shortcut(LogicalKeyboardKey.keyS, ctrl: true, () => save());

// Keyboard visibility (mobile)
vox.keyboard.isVisible    // reactive bool
vox.keyboard.height       // reactive double

// Dismiss keyboard
dismissKeyboard();

// Auto-advance fields in forms
final form = voxForm({
  "email": field(rules: [required, isEmail], next: "pass"),
  "pass":  field(rules: [required], next: "submit"),
});
```

---

## Clipboard and Share

```dart
// Clipboard
copy("Text to copy");
final text = await paste();

// Share
share("Check out this app!");
share("https://example.com", subject: "Cool link");
shareFile(file);
```

---

## Pickers

```dart
final date   = await pickDate();
final time   = await pickTime();
final color  = await pickColor();
final option = await pickOne(["Small", "Medium", "Large"]);
final multi  = await pickMany(["Cheese", "Lettuce", "Tomato"]);
```

---

## Timers, Debounce, and Throttle

```dart
// Debounce (search as you type)
final search = field(debounce: 300.ms);
watch(search, (query) => fetch("api.com/search?q=$query") >> results);

// Throttle
btn("Like").throttle(1.seconds, () => post("api.com/like"));

// Timer
every(5.seconds, () => fetch("api.com/status") >> status);

// Delay
delay(2.seconds, () => toast("Welcome!"));
```

---

## Adaptive Rendering (Material / Cupertino)

```dart
voxApp(
  home: HomeScreen(),
  style: adaptive,   // Cupertino on iOS, Material on Android
  // or
  style: material,   // force Material everywhere
  style: cupertino,  // force Cupertino everywhere
);

// Developer writes same code — vox renders the right widget per platform
btn("Save")          // CupertinoButton on iOS, ElevatedButton on Android
toggle(isDark)       // CupertinoSwitch or Switch
```

---

## Image Caching and Loading

```dart
img("https://example.com/photo.jpg")
  .placeholder(icon(Icons.person))
  .onError(icon(Icons.broken_image))
  .fade
  .fit(cover)
  .circle(48)
```

---

## Lite Import (Tree Shaking)

For minimal apps that only need state + UI, no native dependencies:

```dart
import 'package:vox/vox.dart';          // everything (default)
import 'package:vox/lite.dart';         // state + UI only, no native deps
```

---

## Complete Module Map (Updated)

```
lib/
├── vox.dart                              ← the one import (everything)
├── lite.dart                             ← state + UI only, no native deps
│
└── src/
    ├── api/                              ← SYNTAX LAYER (what devs write)
    │   ├── state.dart                    ← state(), shared(), computed(), watch()
    │   ├── screen.dart                   ← VoxScreen
    │   ├── widget.dart                   ← VoxWidget
    │   ├── layout.dart                   ← col, row, stack, screen, scroll, grid, responsive
    │   ├── widgets.dart                  ← label, btn, icon, img, loader, divider, space, when, toggle
    │   ├── extensions.dart               ← .pad, .expand, .center, .bg, .round, .tap, .flex, .gap ...
    │   ├── net.dart                      ← fetch, post, put, delete, .cache, .stale, .offline
    │   ├── nav.dart                      ← go, back, goNamed, route
    │   ├── storage.dart                  ← save, load, remove, stored, saveSecure, loadSecure
    │   ├── forms.dart                    ← voxForm, field, rules, focusGroup
    │   ├── animation.dart                ← .animate, fade, slide, scale, .hero
    │   ├── permissions.dart              ← ask, check, Permission.*
    │   ├── theme.dart                    ← VoxTheme, vox.theme
    │   ├── device.dart                   ← vox.isWeb, vox.isMobile, vox.screen, vox.keyboard
    │   ├── overlay.dart                  ← dialog, sheet, modal, confirm, close
    │   ├── toast.dart                    ← toast, toast.success, toast.error, toast.warning
    │   ├── tabs.dart                     ← tabs, tab, topTabs
    │   ├── drawer.dart                   ← drawer, navItem, openDrawer, closeDrawer
    │   ├── di.dart                       ← provide, use, override
    │   ├── config.dart                   ← env, VoxEnv
    │   ├── locale.dart                   ← t(), vox.locale, VoxLocale
    │   ├── realtime.dart                 ← connect, socket.on, socket.send
    │   ├── log.dart                      ← log, log.warn, log.error, log.debug
    │   ├── timer.dart                    ← every, delay, .debounce, .throttle
    │   ├── picker.dart                   ← pickDate, pickTime, pickColor, pickOne, pickMany
    │   ├── clipboard.dart                ← copy, paste
    │   ├── share.dart                    ← share, shareFile
    │   └── model.dart                    ← .as<T>, .map, VoxModel
    │
    └── core/                             ← ENGINE LAYER (vox internals, devs never see)
        ├── reactive/
        │   ├── signal.dart               ← signal engine (tracks reads, triggers rebuilds)
        │   ├── state.dart                ← VoxState, VoxListState
        │   ├── shared.dart               ← VoxShared, global shared state
        │   ├── computed.dart             ← VoxComputed, dependency tracking
        │   ├── watcher.dart              ← watch() implementation
        │   ├── scope.dart                ← VoxScope (signal ownership, auto-dispose)
        │   ├── state_view.dart           ← loading/error/empty/data state rendering
        │   └── registry.dart             ← global shared state registry
        ├── screen/
        │   ├── vox_screen.dart           ← VoxScreen base (StatefulWidget wrapper)
        │   └── lifecycle.dart            ← ready, resume, pause, background, foreground, dispose
        ├── widget/
        │   └── vox_widget.dart           ← VoxWidget base
        ├── ui/
        │   ├── layout.dart               ← Column/Row/Stack wrappers with gap/align
        │   ├── widgets.dart              ← widget implementations
        │   ├── responsive.dart           ← breakpoint engine
        │   ├── lazy_list.dart            ← lazy lists, infinite scroll, ListView.builder
        │   ├── refreshable.dart          ← pull-to-refresh
        │   ├── swipe.dart                ← swipe actions
        │   ├── image_cache.dart          ← image loading, caching, placeholder, fallback
        │   ├── skeleton.dart             ← skeleton / shimmer loading
        │   ├── badge.dart                ← badges, notification dots
        │   ├── semantics.dart            ← accessibility, screen reader support
        │   ├── gestures.dart             ← extended gestures (pinch, drag, swipe directions)
        │   └── adaptive.dart             ← Material/Cupertino auto-switching
        ├── net/
        │   ├── client.dart               ← dio client
        │   ├── request.dart              ← VoxRequest (pipeable, chainable)
        │   ├── interceptor.dart          ← base interceptor interface
        │   ├── auth_interceptor.dart     ← authToken, refreshToken
        │   ├── retry_interceptor.dart    ← retry logic
        │   ├── logger_interceptor.dart   ← request logging
        │   ├── cache.dart                ← response caching, stale-while-revalidate
        │   ├── connectivity.dart         ← vox.isOnline, vox.isOffline
        │   └── mapper.dart               ← JSON → typed model mapping
        ├── realtime/
        │   └── websocket.dart            ← WebSocket engine, auto-reconnect
        ├── nav/
        │   ├── router.dart               ← navigation engine
        │   ├── deep_link.dart            ← deep linking, URL params, path params
        │   ├── nav_io.dart               ← mobile nav
        │   └── nav_web.dart              ← web browser history nav
        ├── tabs/
        │   └── tab_engine.dart           ← bottom nav, top tabs
        ├── overlay/
        │   └── overlay_engine.dart       ← dialogs, sheets, modals
        ├── toast/
        │   └── toast_engine.dart         ← toast/snackbar engine
        ├── drawer/
        │   └── drawer_engine.dart        ← drawer management
        ├── storage/
        │   ├── storage.dart              ← abstract StorageAdapter
        │   ├── storage_io.dart           ← SharedPreferences impl
        │   └── storage_web.dart          ← localStorage impl
        ├── secure/
        │   ├── secure.dart               ← abstract SecureAdapter
        │   ├── secure_io.dart            ← flutter_secure_storage impl
        │   └── secure_web.dart           ← encrypted localStorage impl
        ├── permissions/
        │   ├── permissions.dart          ← abstract PermissionAdapter
        │   ├── permissions_io.dart       ← permission_handler impl
        │   └── permissions_web.dart      ← browser permissions API
        ├── theme/
        │   └── theme_engine.dart         ← VoxTheme, theme registry, dark/light/system
        ├── forms/
        │   ├── form.dart                 ← VoxForm engine
        │   ├── rules.dart                ← validation rule implementations
        │   └── focus.dart                ← focus management, auto-advance
        ├── animation/
        │   ├── animator.dart             ← animation engine
        │   └── hero.dart                 ← shared element transitions
        ├── locale/
        │   ├── locale_engine.dart        ← i18n engine
        │   └── translations.dart         ← translation loading/lookup
        ├── di/
        │   ├── container.dart            ← service container
        │   └── provider.dart             ← provide/use implementation
        ├── config/
        │   └── env.dart                  ← environment configuration
        ├── device/
        │   └── device_info.dart          ← platform/device detection
        ├── keyboard/
        │   └── keyboard_engine.dart      ← keyboard visibility, shortcuts
        ├── clipboard/
        │   └── clipboard_engine.dart     ← copy/paste
        ├── share/
        │   └── share_engine.dart         ← native share sheet
        ├── picker/
        │   └── picker_engine.dart        ← date/time/color/option pickers
        ├── timer/
        │   └── timer_engine.dart         ← debounce, throttle, intervals
        ├── log/
        │   └── logger.dart               ← leveled logging
        ├── errors/
        │   ├── vox_error.dart            ← VoxError base class
        │   ├── messages.dart             ← all error message strings (vox language)
        │   └── error_handler.dart        ← crash reporting hooks, global error handler
        └── app/
            ├── vox_app.dart              ← voxApp() entry point, MaterialApp wrapper
            ├── initializer.dart          ← splash, async init, onReady
            └── lifecycle.dart            ← global app lifecycle (background, foreground, terminate)
```

---

## Compatibility Promise

Vox never takes over Flutter. It only adds to it.

```dart
// Raw Flutter still works inside any VoxScreen
@override
get view => screen("Mixed", [
  label("Vox widget"),
  // Raw Flutter widget — works fine
  Container(
    decoration: BoxDecoration(...),
    child: RawFlutterWidget(),
  ),
  // Any package — works fine
  fl_chart.LineChart(...),
]);
```

No lock-in. Ever.
