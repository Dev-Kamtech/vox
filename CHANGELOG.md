## 0.4.0

- **Phase 8 — Tabs**: `tabs([tab("Home", Icons.home, HomeScreen())])` — bottom navigation bar with `IndexedStack` state preservation. `topTabs("Title", [...])` — `AppBar` + `TabBar` + `TabBarView`. `tab()` factory for both.
- **Phase 8 — Drawer**: `drawer([navItem("Home", Icons.home, onTap: ...)])` — side navigation drawer. `openDrawer()` / `closeDrawer()` work from anywhere without BuildContext. `screen()` gains `drawer:` and `floatingActionButton:` params.
- **Phase 8 — Share**: `shareText()`, `shareLink()`, `shareFiles()` — native share sheet via `share_plus`. `VoxShare` static facade for direct calls.
- **Phase 8 — Config / Env**: `VoxEnv.configure({...})` at startup, then `env("API_URL")` anywhere. `env("KEY", fallback: "value")` for safe access. Throws `VoxError` with a clear hint if key is missing.
- **Phase 8 — Permissions**: `ask(VoxPermission.camera)`, `check(VoxPermission.location)` — runtime permission requests via `permission_handler`. `openPermissionSettings()` sends user to device settings.
- **Phase 8 — Pickers**: `pickDate()`, `pickTime()`, `pickOne(options)`, `pickMany(options)` — context-free pickers using the global navigator key. All return `null` on cancel.

## 0.3.0

- **Phase 7 — Animations**: `.animate(preset)` widget extension with built-in presets (`fade`, `scale`, `slide.fromBottom/Top/Left/Right`), chainable `.duration(ms)`, `anim<T>()` for smooth value-change transitions. `.hero(tag)` extension for shared-element transitions.
- **Phase 7 — Theme**: `VoxTheme` token class (`primary`, `background`, `surface`, `text`, `radius`, `dark`). `VoxThemeController` singleton for runtime switching (`vox.theme.toggle()`, `vox.theme.set(...)`). `voxApp(theme:)` now accepts `VoxTheme` (replaces raw `ThemeData`). App wraps `MaterialApp` in `ListenableBuilder` for reactive theme changes.
- **Phase 7 — Device & Platform**: Global `vox` context — `vox.isIOS`, `vox.isAndroid`, `vox.isMobile`, `vox.isDesktop`, `vox.isWeb`. `vox.device.name` / `vox.device.os` via `device_info_plus`. `vox.theme.*` shortcuts.
- **Phase 7 — DI**: `provide<T>()`, `use<T>()`, `has<T>()` — type-based service locator with no string keys. `VoxContainer.override<T>()` for test doubles.
- `voxApp()` gains `init: Future<void> Function()?` — async startup hook called post-first-frame.

## 0.2.0

- **Phase 4 — Reactive state fully wired**: `shared()` (app-global state), `computed()` (derived signals with dependency tracking), `watch()` (side-effect listener), `stored()` (persisted state via SharedPreferences), `VoxListState` operations (`each`, `where`, `search`, `sort`, `paginate`), `List<Widget>` extensions (`.col`, `.row`, `.stack`)
- **Phase 5 — Networking, Navigation, Storage**: `VoxClient` (Dio wrapper with `configureHttp()`), `VoxRequest<T>` with `>>` pipe operator, `.loading()` and `.onError()` chains; `VoxRouter` with context-free navigation (`go()`, `back()`, `canBack`); `VoxStorage` (SharedPreferences) and `VoxSecure` (FlutterSecureStorage)
- **Phase 6 — Forms, UI utilities**: `VoxField` (reactive form field with `.input` widget + two-way sync), `VoxForm` (batch validate/submit), `VoxToast` (floating snackbar with success/warning/error types), `VoxOverlay` (`alert()`, `confirm()`, `sheet()`), `VoxLog` (ANSI-colored leveled logger with global `log` singleton), `VoxTimer` (`delay()`, `every()`), `VoxClipboard` (`copy()`, `paste()`)

## 0.1.0

- Initial package structure
- API layer: 25 syntax modules (state, screen, widget, layout, widgets, extensions, net, nav, storage, forms, animation, permissions, theme, device, overlay, toast, tabs, drawer, di, config, locale, realtime, log, timer, picker, clipboard, share, model)
- Core engine layer: 20 modules (~60 files)
- Two barrel exports: `vox.dart` (full) and `lite.dart` (minimal)
- Design document with full API surface
