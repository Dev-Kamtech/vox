import 'package:vox/vox.dart';

// ── THEME ────────────────────────────────────────────────────────────────────

const _void     = Color(0xFF050A05);
const _surface  = Color(0xFF0B130B);
const _surface2 = Color(0xFF111B11);
const _surface3 = Color(0xFF162016);
const _bot      = Color(0xFFFF6D3B);
const _botGlow  = Color(0x28FF6D3B);
const _botDeep  = Color(0x14FF6D3B);
const _text     = Color(0xFFF5F5F5);
const _textDim  = Color(0xFF4A6A4A);
const _border   = Color(0xFF172117);

// ── ENTRY ────────────────────────────────────────────────────────────────────

void main() => voxApp(
      theme: const VoxTheme(
        primary:    _bot,
        background: _void,
        surface:    _surface,
        text:       _text,
        radius:     16,
        dark: VoxTheme(
          primary: _bot, background: _void,
          surface: _surface, text: _text, radius: 16,
        ),
      ),
      init: _boot,
      home: SplashScreen(),
    );

// ── DATA MODEL ────────────────────────────────────────────────────────────────

class Msg extends VoxModel {
  final String id, text;
  final bool fromUser;
  final DateTime at;

  Msg({
    required this.id,
    required this.text,
    required this.fromUser,
    DateTime? at,
  }) : at = at ?? DateTime.now();

  @override
  Msg decode(Map<String, dynamic> j) => Msg(
        id: j.str('id'), text: j.str('text'),
        fromUser: j.flag('fromUser'), at: j.date('at'),
      );

  @override
  Map<String, dynamic> encode() => {
        'id': id, 'text': text,
        'fromUser': fromUser, 'at': at.toIso8601String(),
      };
}

// ── DATA SOURCES ──────────────────────────────────────────────────────────────

final _msgs      = state(<Msg>[]);
final _thinking  = state(false);
final _pulse     = state(1.0);
final _apiKey    = state<String?>(null);  // null = not set yet
final _bootDone  = state(false);          // true after secure-storage check

// ── DATA ACTIONS ──────────────────────────────────────────────────────────────

VoidCallback? _pulseTimer;

Future<void> _boot() async {
  final stored = await loadSecure('gemini_key');
  if (stored is String && stored.isNotEmpty) {
    _apiKey.set(stored);
  }
  _bootDone.set(true);
}

void _userSend(String text) {
  _msgs.update((list) => [
    ...list,
    Msg(id: _id(), text: text, fromUser: true),
  ]);
  _beginThinking();
  _geminiCall(); // unawaited — async, updates state when done
}

// Calls Gemini with the full conversation history (last 20 turns).
void _geminiCall() async {
  final key      = _apiKey.peek;
  if (key == null) { _endThinking(); return; }

  final history  = _msgs.peek.reversed.take(20).toList().reversed.toList();
  final contents = history.map((m) => {
    'role':  m.fromUser ? 'user' : 'model',
    'parts': [{'text': m.text}],
  }).toList();

  try {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-1.5-flash:generateContent?key=$key';

    final result = await post(
      url,
      body: {
        'system_instruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.85,
          'maxOutputTokens': 800,
        },
      },
    ) as Map<String, dynamic>;

    final text =
        ((result['candidates'] as List).first['content']['parts'] as List)
            .first['text'] as String;

    _endThinking();
    _msgs.update((list) => [
      ...list,
      Msg(id: _id(), text: text.trim(), fromUser: false),
    ]);
  } catch (_) {
    _endThinking();
    _msgs.update((list) => [
      ...list,
      Msg(
        id: _id(),
        text: 'Something went wrong. '
            'Check your API key or internet connection.',
        fromUser: false,
      ),
    ]);
  }
}

void _saveKey(String key) async {
  await saveSecure('gemini_key', key);
  _apiKey.set(key);
}

void _clearKey() async {
  await removeSecure('gemini_key');
  _apiKey.set(null);
  _msgs.set([]);
}

void _beginThinking() {
  _thinking.set(true);
  _pulse.set(0.82);
  _pulseTimer = every(const Duration(milliseconds: 680), () {
    _pulse.update((v) => v < 1.0 ? 1.12 : 0.82);
  });
}

void _endThinking() {
  _pulseTimer?.call();
  _pulseTimer = null;
  _pulse.set(1.0);
  _thinking.set(false);
}

String _id() => DateTime.now().microsecondsSinceEpoch.toString();

const _systemPrompt =
    'You are Aether, a sharp and friendly AI assistant built into a Flutter '
    'app called Aether, powered by the vox framework — a Flutter package '
    'that gives full-stack app capabilities with one import. '
    'Be concise, warm, and genuinely helpful. When vox is relevant, '
    'mention it naturally. Keep responses to 2–4 sentences unless '
    'the user clearly wants more detail.';

// ── SCREENS ───────────────────────────────────────────────────────────────────

class SplashScreen extends VoxScreen {
  @override
  void ready() => delay(
      const Duration(milliseconds: 2400),
      () => go(BotScreen(), replace: true));

  @override
  Widget get view => scaffold(
        safe(col([
          _botAvatar(76).animate(scale).duration(500),
          gap(20),
          label('AETHER').heavy.size(13).color(_textDim).letterSpacing(4),
          gap(32),
          label('made with').size(11).color(_textDim).letterSpacing(1),
          gap(6),
          _wordmark().animate(scale).duration(650),
          gap(6),
          label('one import. full power.')
              .size(11).color(_textDim).letterSpacing(0.5),
        ]).centered.center),
        bg: _void,
      );
}

class BotScreen extends VoxScreen {
  // Chat input
  final _msgField = field(initial: '', hint: 'Ask anything...');
  late final _form = voxForm({'msg': _msgField});

  // Key setup input
  final _keyField = field(initial: '', hint: 'Paste your Gemini API key here');
  late final _keyForm = voxForm({'key': _keyField});

  @override
  Widget get view {
    final bootDone = _bootDone.val;
    final apiKey   = _apiKey.val;
    final msgs     = _msgs.val;
    final busy     = _thinking.val;
    final pulse    = _pulse.val;

    // ── Loading ─────────────────────────────────────────────────────────────
    if (!bootDone) {
      return scaffold(
        loader(size: 32, color: _bot).center,
        bg: _void,
      );
    }

    // ── Key setup ───────────────────────────────────────────────────────────
    if (apiKey == null) {
      return scaffold(
        safe(col([
          gap(20),
          _botAvatar(64).animate(scale).duration(500).center,
          gap(20),
          label('Connect Aether to Gemini')
              .heavy.size(22).color(_text).center,
          gap(8),
          label('Aether uses Google Gemini to respond.\nGet a free key in 2 minutes.')
              .size(14).color(_textDim).center,
          gap(32),
          // Step list
          _setupStep('1', 'Go to aistudio.google.com'),
          gap(10),
          _setupStep('2', 'Sign in with any Google account'),
          gap(10),
          _setupStep('3', 'Tap "Get API key" → "Create API key"'),
          gap(10),
          _setupStep('4', 'Copy and paste it below'),
          gap(28),
          // Key input
          card(
            _keyField.input,
            color: _surface2,
            borderColor: _border,
            radius: 14,
            pad: 4,
          ),
          gap(14),
          label('Connect')
              .semibold
              .size(15)
              .color(Colors.white)
              .center
              .pad(v: 14)
              .bg(_bot)
              .round(14)
              .tap(_doSaveKey),
          gap(8),
          label('Free tier · 1,500 req/day · your key stays on your device')
              .size(11)
              .color(_textDim)
              .center,
        ]).pad(h: 24).scrollable),
        bg: _void,
      );
    }

    // ── Chat ─────────────────────────────────────────────────────────────────
    return scaffold(
      col([
        // Header
        safe(
          row([
            anim(pulse,
              builder: (v) => _botAvatar(40).scaleBy(v),
              duration: const Duration(milliseconds: 650),
            ),
            hgap(12),
            col([
              label('Aether').semibold.size(17).color(_text),
              row([
                space(7).bg(busy ? _bot : _textDim).round(4).animate(scale),
                hgap(6),
                label(busy ? 'Thinking...' : 'Ready')
                    .size(11).color(busy ? _bot : _textDim),
              ]),
            ]).left.expand,
            icon(Icons.logout_rounded, color: _textDim, size: 20)
                .pad(all: 6)
                .tap(() => confirm(
                      'Change API key?',
                      message: 'This will clear the conversation and return to setup.',
                    ).then((ok) { if (ok) _clearKey(); }),
                ),
          ]).pad(h: 16, v: 12),
          bottom: false,
        ).bg(_surface).border(_border),

        // Messages
        when(
          msgs.isEmpty && !busy,
          _emptyState(),
        ),
        when(
          msgs.isNotEmpty || busy,
          col([
            list(
              msgs.reversed.toList(),
              (m, i) => _bubble(m),
              padTop: 16, padBottom: 8,
              reverse: true,
            ).expand,
            when(busy, _thinkingBubble(pulse)),
          ]).stretched.expand,
        ),

        // Input
        safe(
          row([
            _msgField.input.expand,
            hgap(10),
            _sendBtn(busy),
          ]).pad(h: 14, v: 10),
          top: false,
        ).bg(_surface).border(_border, width: 0.5),
      ]).stretched,
      bg: _void,
    );
  }

  Widget _sendBtn(bool busy) => anim(
        busy ? 0.78 : 1.0,
        builder: (v) => icon(
          busy ? Icons.hourglass_top_rounded : Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 17,
        ).center.sized(44, 44).bg(busy ? _surface3 : _bot).round(22).scaleBy(v),
        duration: const Duration(milliseconds: 300),
      ).tap(busy ? () {} : _submit);

  void _submit() {
    final text = _form['msg']!.peek.trim();
    if (text.isEmpty) return;
    _form.reset();
    _userSend(text);
  }

  void _doSaveKey() {
    final key = _keyForm['key']!.peek.trim();
    if (key.length < 20) return; // clearly not a valid key
    _saveKey(key);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

Widget _botAvatar(double size) => card(
      icon(Icons.auto_awesome_rounded, color: Colors.white, size: size * 0.46)
          .center.sized(size, size),
      color:       _bot,
      borderColor: _botGlow,
      radius:      size * 0.28,
    );

Widget _wordmark() => row([
      label('v').heavy.size(42).color(_bot),
      label('o').heavy.size(42).color(_text),
      label('x').heavy.size(42).color(_bot),
    ]);

Widget _setupStep(String num, String text) => row([
      label(num)
          .semibold.size(12).color(_bot)
          .center.sized(26, 26)
          .bg(_botDeep).round(13),
      hgap(12),
      label(text).size(14).color(_text).expand,
    ]);

Widget _emptyState() => col([
      gap(50),
      _botAvatar(72).animate(scale).duration(600),
      gap(24),
      label('Hi, I\'m Aether').heavy.size(24).color(_text).center,
      gap(8),
      label('Powered by Gemini  ·  Ask me anything')
          .size(14).color(_textDim).center,
      gap(36),
      _chip('What can you do?'),
      gap(10),
      _chip('Tell me something interesting'),
      gap(10),
      _chip('What is the vox framework?'),
    ]).centered.center.expand;

Widget _chip(String text) => label(text)
    .size(13).color(_textDim)
    .pad(h: 18, v: 10)
    .bg(_surface2).round(22).border(_border)
    .tap(() => _userSend(text));

Widget _bubble(Msg m) {
  final isUser = m.fromUser;
  return row([
    if (!isUser) _botAvatar(28).pad(right: 8, bottom: 16),
    if (isUser) spacer,
    col([
      label(m.text).size(14).color(_text)
          .pad(h: 14, v: 10)
          .bg(isUser ? _surface2 : _botDeep)
          .round(18)
          .border(isUser ? _border : _botGlow, radius: 18),
      gap(3),
      label(_time(m.at)).size(10).color(_textDim)
          .alignTo(isUser ? Alignment.centerRight : Alignment.centerLeft),
    ]).maxW(290),
    if (!isUser) spacer,
  ])
      .pad(h: 16, v: 3)
      .animate(isUser ? slide.fromRight : slide.fromLeft)
      .duration(260);
}

Widget _thinkingBubble(double pulse) => row([
      anim(pulse,
        builder: (v) => _botAvatar(28).scaleBy(v).pad(right: 8, bottom: 14),
        duration: const Duration(milliseconds: 650),
      ),
      col([
        row([
          _pulseDot(pulse, 0), hgap(5),
          _pulseDot(pulse, 1), hgap(5),
          _pulseDot(pulse, 2),
        ])
            .pad(h: 16, v: 13)
            .bg(_botDeep).round(18).border(_botGlow, radius: 18),
        gap(3),
        label('Thinking...').size(10).color(_bot),
      ]),
      spacer,
    ]).pad(h: 16, v: 4).animate(fade).duration(200);

Widget _pulseDot(double pulse, int index) {
  final offsets = [0.0, 0.15, 0.30];
  final effective = ((pulse - 0.82) / 0.30 + offsets[index]).clamp(0.0, 1.0);
  return anim(
    0.7 + effective * 0.6,
    builder: (v) => space(7).bg(_bot).round(4).scaleBy(v),
    duration: const Duration(milliseconds: 400),
  );
}

// ── UTILS ──────────────────────────────────────────────────────────────────────

String _time(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
