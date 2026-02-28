import 'package:vox/vox.dart';

// ── THEME ────────────────────────────────────────────────────────────────────
// Define once. Used everywhere.

const _purple     = Color(0xFF6C63FF);
const _purpleGlow = Color(0xFF9D97FF);
const _bg         = Color(0xFF0A0A12);
const _surface    = Color(0xFF12121E);
const _surface2   = Color(0xFF1C1C2A);
const _text       = Color(0xFFF0F0FF);
const _textDim    = Color(0xFF6E6E8E);
const _green      = Color(0xFF4CAF82);
const _red        = Color(0xFFFF6584);

// ── ENTRY ────────────────────────────────────────────────────────────────────
// App starts here. Theme applied. Data loaded. Then go to splash.

void main() => voxApp(
      theme: const VoxTheme(
        primary: _purple, background: _bg, surface: _surface, text: _text,
        radius: 16,
        dark: VoxTheme(primary: _purple, background: _bg, surface: _surface, text: _text, radius: 16),
      ),
      init: _loadTodos,
      home: SplashScreen(),
    );

// ── DATA MODEL ───────────────────────────────────────────────────────────────
// What a Todo looks like. Knows how to read/write itself.

class Todo extends VoxModel {
  final String id, title;
  final bool done;
  final DateTime createdAt;

  Todo({required this.id, required this.title, this.done = false, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  @override
  Todo decode(Map<String, dynamic> j) => Todo(
        id:        j.str('id'),
        title:     j.str('title'),
        done:      j.flag('done'),
        createdAt: j.date('createdAt'),
      );

  @override
  Map<String, dynamic> encode() => {
        'id':        id,
        'title':     title,
        'done':      done,
        'createdAt': createdAt.toIso8601String(),
      };
}

// ── DATA SOURCE ───────────────────────────────────────────────────────────────
// One reactive list. Lives in memory. Persists to storage.

final _todos = state(<Todo>[]);

Future<void> _loadTodos() async {
  final raw = await load('todos');
  if (raw is List) {
    _todos.set(
      raw.whereType<Map<String, dynamic>>()
          .map((e) => Todo(id: '', title: '').decode(e))
          .toList(),
    );
  }
}

Future<void> _persist() =>
    save('todos', _todos.peek.map((t) => t.encode()).toList());

// ── DATA ACTIONS ──────────────────────────────────────────────────────────────
// What the user can do with todos.

Future<void> _addTodo(String title) async {
  _todos.set([
    ..._todos.peek,
    Todo(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
  ]);
  await _persist();
}

Future<void> _toggleTodo(String id) async {
  _todos.set(_todos.peek
      .map((t) => t.id == id ? t.copyWith<Todo>({'done': !t.done}) : t)
      .toList());
  await _persist();
}

Future<void> _deleteTodo(String id) async {
  _todos.set(_todos.peek.where((t) => t.id != id).toList());
  await _persist();
}

Future<void> _clearAll() async {
  _todos.set([]);
  await save('todos', <dynamic>[]);
}

// ── SPLASH ───────────────────────────────────────────────────────────────────
// Shows on launch. Navigates to home after 2.6 seconds.

class SplashScreen extends VoxScreen {
  @override
  void ready() =>
      delay(const Duration(milliseconds: 2600), () => go(HomeScreen(), replace: true));

  @override
  Widget get view => scaffold(
        safe(_logo().center),
        bg: _bg,
      );
}

// ── HOME ──────────────────────────────────────────────────────────────────────
// Three tabs: active todos, done todos, settings.
// Shows a + button only on the active tab.

class HomeScreen extends VoxScreen {
  final _tab = state(0);

  @override
  Widget get view {
    final all  = _todos.val;
    final done = all.where((t) => t.done).toList();
    final pct  = all.isEmpty ? 0.0 : done.length / all.length;

    return scaffold(
      safe(col([
        _header(done.length, all.length, pct),
        indexed(_tab.val, [
          _activeTab(all.where((t) => !t.done).toList()),
          _doneTab(done),
          _settingsTab(),
        ]).expand,
      ]).stretched),
      bg:  _bg,
      fab: _tab.val == 0
          ? fab(Icons.add_rounded, () => go(AddTodoScreen()), color: _purple)
          : null,
      nav: _bottomNav(_tab.val, _tab.set),
    );
  }
}

// ── ADD SCREEN ────────────────────────────────────────────────────────────────
// Form screen. Validates input. Adds todo on submit.

class AddTodoScreen extends VoxScreen {
  final _titleField = field(
    initial: '',
    rules:   [Rules.required, Rules.minLength(3)],
    hint:    'What needs to be done?',
  );

  late final _form = voxForm({'title': _titleField});

  @override
  Widget get view => scaffold(
        safe(col([
          // Top bar
          row([
            _backBtn(),
            hgap(12),
            label('New Task').heavy.size(20).color(_text),
          ]).pad(all: 16),
          gap(32),
          // Form
          col([
            label('Task name').size(13).color(_textDim),
            gap(8),
            _titleField.input,
            gap(28),
            _primaryBtn('Add Task', Icons.add_rounded, _submit),
            gap(12),
            _primaryBtn('Cancel', Icons.close_rounded, back, outlined: true),
          ]).left.pad(h: 20),
        ]).left),
        bg: _bg,
      );

  void _submit() => _form.submit(() async {
        await _addTodo(_form['title']!.peek);
        back();
      });
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB BODIES
// Each returns a widget. Reads data passed in from HomeScreen.
// ═════════════════════════════════════════════════════════════════════════════

Widget _activeTab(List<Todo> active) => active.isEmpty
    ? _emptyState(Icons.check_circle_outline_rounded,
        "You're all caught up!", 'Tap + to add a task')
    : list(active, (t, i) => _todoTile(t, i),
        padH: 16, padTop: 12, padBottom: 90);

Widget _doneTab(List<Todo> done) => done.isEmpty
    ? _emptyState(Icons.hourglass_empty_rounded,
        'Nothing done yet', 'Complete a task to see it here')
    : list(done, (t, i) => _todoTile(t, i), pad: 16);

Widget _settingsTab() => scroll([
      label('Settings').heavy.size(22).color(_text),
      gap(20),
      _settingCard(switchTile(
        'Dark mode', vox.theme.isDark, (_) => vox.theme.toggle(),
        subtitle: 'Toggle app theme',
        activeColor: _purple,
        padH: 16,
      )),
      gap(10),
      _settingCard(tile(
        'Clear all todos',
        leading: icon(Icons.delete_sweep_rounded, color: _red, size: 22),
        titleColor: _red,
        onTap: _clearAll,
        padH: 16,
      )),
      gap(28),
      _aboutCard(),
    ]).pad(all: 16, bottom: 40);

// ═════════════════════════════════════════════════════════════════════════════
// COMPONENTS
// Plain functions. No classes. Read the name → know what it does.
// ═════════════════════════════════════════════════════════════════════════════

// App logo shown on splash and branding cards.
Widget _logo() => col([
      card(
        icon(Icons.check_rounded, color: _purple, size: 46).center
            .sized(96, 96),
        color:       const Color(0x266C63FF),
        borderColor: const Color(0x806C63FF),
        radius: 48,
      ).animate(scale).duration(500),
      gap(40),
      label('made with').size(13).color(_textDim).letterSpacing(1),
      gap(10),
      _wordmark().animate(scale).duration(600),
      gap(10),
      label('one import. full power.').size(12).color(_textDim).letterSpacing(0.5),
    ]);

Widget _wordmark() => row([
      label('v').heavy.size(54).color(_purple),
      label('o').heavy.size(54).color(_purpleGlow),
      label('x').heavy.size(54).color(_purple),
    ]);

// Header shows task count and animated progress bar.
Widget _header(int done, int total, double pct) => col([
      row([
        col([
          label('My Tasks').heavy.size(22).color(_text),
          gap(4),
          label('$done of $total completed').size(13).color(_textDim),
          gap(12),
          anim(pct, builder: (v) =>
              progress(v, color: _purple, bg: _surface2, height: 6).round(4)),
        ]).left.expand,
        hgap(16),
        anim(pct, builder: (v) => stack([
              ring(v, size: 58, color: _purple, bg: _surface2, width: 5),
              label('${(v * 100).toInt()}%').bold.size(11).color(_text)
                  .center.sized(58, 58),
            ])),
      ]).pad(all: 20, bottom: 16),
      divider,
    ]).bg(_surface);

// Bottom navigation bar with 3 tabs.
Widget _bottomNav(int current, void Function(int) onTap) =>
    safe(
      row([
        _navItem(Icons.checklist_rounded,            'Active',   0, current, onTap),
        _navItem(Icons.check_circle_outline_rounded, 'Done',     1, current, onTap),
        _navItem(Icons.tune_rounded,                 'Settings', 2, current, onTap),
      ]).stretched,
      top: false,
    ).bg(_surface).border(const Color(0x1A6C63FF));

Widget _navItem(IconData ico, String lbl, int i, int cur,
    void Function(int) onTap) {
  final on = i == cur;
  return col([
    icon(ico, color: on ? _purple : _textDim, size: 22)
        .pad(all: 6)
        .bg(on ? const Color(0x266C63FF) : Colors.transparent)
        .round(10),
    gap(3),
    label(lbl)
        .size(11)
        .color(on ? _purple : _textDim)
        .weight(on ? FontWeight.w600 : FontWeight.normal),
  ]).pad(v: 12).expand.tap(() => onTap(i));
}

// A single todo item. Swipe left to delete. Tap checkbox to toggle.
Widget _todoTile(Todo todo, int i) => swipeable(
      todo.id,
      card(
        row([
          _checkbox(todo),
          hgap(12),
          col([
            toggle(
              todo.done,
              label(todo.title).size(15).color(_textDim).strikethrough,
              label(todo.title).size(15).color(_text).medium,
            ),
            gap(2),
            label(_timeAgo(todo.createdAt)).size(11).color(_textDim),
          ]).left.expand,
        ]).pad(h: 16, v: 12),
        color:       _surface,
        radius:      16,
        borderColor: todo.done ? const Color(0x334CAF82) : const Color(0x146C63FF),
      ).pad(bottom: 10),
      () => _deleteTodo(todo.id),
      bg: card(
        icon(Icons.delete_outline_rounded, color: _red)
            .bottomRight.pad(right: 20),
        color:       const Color(0x26FF6584),
        borderColor: const Color(0x66FF6584),
        radius: 16,
      ).pad(bottom: 10),
    ).animate(slide.fromBottom).duration(300 + i * 40);

// Checkbox: filled green when done, outlined when not.
Widget _checkbox(Todo todo) => toggle(
      todo.done,
      icon(Icons.check_rounded, color: Colors.white, size: 16)
          .center.sized(26, 26).bg(_green).round(8),
      space(0).sized(26, 26)
          .border(const Color(0x806E6E8E), radius: 8),
    ).tap(() => _toggleTodo(todo.id));

// Empty state shown when a tab has no items.
Widget _emptyState(IconData ico, String title, String sub) => col([
      icon(ico, color: _textDim, size: 34)
          .center.sized(72, 72).bg(_surface2).round(36)
          .animate(scale),
      gap(20),
      label(title).bold.size(17).color(_text).animate(fade).duration(400),
      gap(6),
      label(sub).size(13).color(_textDim).animate(fade).duration(600),
    ]).centered.center;

// Wraps settings items in a card.
Widget _settingCard(Widget child) =>
    card(child, color: _surface, radius: 16, borderColor: const Color(0x146C63FF));

// "Built with vox" promotional card shown in Settings.
Widget _aboutCard() => col([
      row([
        card(
          icon(Icons.bolt_rounded, color: _purple, size: 24).center.sized(42, 42),
          color: const Color(0x336C63FF), radius: 12,
        ),
        hgap(12),
        col([
          label('Built with vox').bold.size(15).color(_text),
          label('v0.5.0  ·  pub.dev/packages/vox').size(11).color(_textDim),
        ]).left,
      ]),
      gap(14),
      divider,
      gap(14),
      label('One import. Full power.').semibold.size(13).color(_purpleGlow),
      gap(6),
      label('State · Nav · HTTP · Storage · Forms · Animations\n'
          'Themes · WebSocket · Locale · DI · Tabs · and more.')
          .size(12).color(_textDim),
    ])
        .pad(all: 20)
        .bg(const Color(0xFF0E0E1A))
        .border(const Color(0x406C63FF), radius: 20)
        .animate(fade).duration(600);

// Back button used in sub-screens.
Widget _backBtn() => card(
      icon(Icons.arrow_back_ios_new_rounded, color: _text, size: 18)
          .center.sized(40, 40),
      color: _surface, radius: 12,
    ).tap(back);

// Full-width action button (solid or outlined).
Widget _primaryBtn(String lbl, IconData ico, VoidCallback onTap,
        {bool outlined = false}) =>
    row([
      icon(ico, color: outlined ? _textDim : Colors.white, size: 18),
      hgap(8),
      label(lbl)
          .semibold
          .size(15)
          .color(outlined ? _textDim : Colors.white),
    ]).centered.pad(v: 16)
        .bg(outlined ? Colors.transparent : _purple)
        .border(outlined ? const Color(0x4D6E6E8E) : _purple, radius: 16)
        .w(double.infinity)
        .tap(onTap);

// ── UTILS ─────────────────────────────────────────────────────────────────────

String _timeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours   < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
