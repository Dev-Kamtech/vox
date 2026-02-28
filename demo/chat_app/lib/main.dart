import 'package:vox/vox.dart';

// ── THEME ────────────────────────────────────────────────────────────────────
// Very black with a whisper of green. Orange is the bot. White is the voice.

const _void     = Color(0xFF050A05);   // near-pure black, barely green
const _surface  = Color(0xFF0B130B);   // one shade up
const _surface2 = Color(0xFF111B11);   // card / input bg
const _surface3 = Color(0xFF162016);   // slightly lighter card

const _bot      = Color(0xFFFF6D3B);   // bot orange — warm, Claude-like
const _botGlow  = Color(0x28FF6D3B);   // faint orange glow
const _botDeep  = Color(0x14FF6D3B);   // very faint, for bot bubble bg

const _text     = Color(0xFFF5F5F5);   // clean white
const _textDim  = Color(0xFF4A6A4A);   // greenish-grey, very muted
const _border   = Color(0xFF172117);   // barely-visible green border

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
// The conversation. Whether the bot is thinking. How much it pulses.

final _msgs       = state(<Msg>[]);
final _thinking   = state(false);
final _pulse      = state(1.0);   // drives the breathing animation

// ── DATA ACTIONS ──────────────────────────────────────────────────────────────

VoidCallback? _pulseTimer;

void _userSend(String text) {
  _msgs.update((list) => [
    ...list,
    Msg(id: _id(), text: text, fromUser: true),
  ]);
  _beginThinking();
  delay(
    Duration(milliseconds: 1600 + text.length * 18),
    () {
      _endThinking();
      _msgs.update((list) => [
        ...list,
        Msg(id: _id(), text: _reply(text), fromUser: false),
      ]);
    },
  );
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

// ── SCREENS ───────────────────────────────────────────────────────────────────

class SplashScreen extends VoxScreen {
  @override
  void ready() => delay(
      const Duration(milliseconds: 2600),
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
  final _field = field(initial: '', hint: 'Ask anything...');
  late final _form = voxForm({'msg': _field});

  @override
  Widget get view {
    final msgs    = _msgs.val;
    final busy    = _thinking.val;
    final pulse   = _pulse.val;

    return scaffold(
      col([
        // ── Header ────────────────────────────────────────────────────────
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
                space(7)
                    .bg(busy ? _bot : _textDim)
                    .round(4)
                    .animate(scale),
                hgap(6),
                anim(busy ? 1.0 : 0.0,
                  builder: (_) => label(busy ? 'Thinking...' : 'Ready')
                      .size(11)
                      .color(busy ? _bot : _textDim),
                  duration: const Duration(milliseconds: 200),
                ),
              ]),
            ]).left.expand,
            icon(Icons.info_outline_rounded, color: _textDim, size: 20)
                .pad(all: 6),
          ]).pad(h: 16, v: 12),
          bottom: false,
        ).bg(_surface).border(_border),

        // ── Messages ──────────────────────────────────────────────────────
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
              padTop: 16,
              padBottom: 8,
              reverse: true,
            ).expand,
            when(busy, _thinkingBubble(pulse)),
          ]).stretched.expand,
        ),

        // ── Input bar ─────────────────────────────────────────────────────
        safe(
          row([
            _field.input.expand,
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
          busy
              ? Icons.hourglass_top_rounded
              : Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 17,
        )
            .center
            .sized(44, 44)
            .bg(busy ? _surface3 : _bot)
            .round(22)
            .scaleBy(v),
        duration: const Duration(milliseconds: 300),
      ).tap(busy ? () {} : _submit);

  void _submit() {
    final text = _form['msg']!.peek.trim();
    if (text.isEmpty) return;
    _form.reset();
    _userSend(text);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

// The bot's face — orange rounded square with the spark icon.
Widget _botAvatar(double size) => card(
      icon(Icons.auto_awesome_rounded, color: Colors.white, size: size * 0.46)
          .center
          .sized(size, size),
      color:       _bot,
      borderColor: _botGlow,
      radius:      size * 0.28,
    );

Widget _wordmark() => row([
      label('v').heavy.size(42).color(_bot),
      label('o').heavy.size(42).color(_text),
      label('x').heavy.size(42).color(_bot),
    ]);

// Empty state — shown when conversation is blank.
Widget _emptyState() => col([
      gap(50),
      _botAvatar(72).animate(scale).duration(600),
      gap(24),
      label('Hi, I\'m Aether').heavy.size(24).color(_text).center,
      gap(8),
      label('Built with vox  ·  Ask me anything')
          .size(14).color(_textDim).center,
      gap(36),
      _chip('What is vox?'),
      gap(10),
      _chip('Tell me something interesting'),
      gap(10),
      _chip('How does this app work?'),
    ]).centered.center.expand;

Widget _chip(String text) => label(text)
    .size(13)
    .color(_textDim)
    .pad(h: 18, v: 10)
    .bg(_surface2)
    .round(22)
    .border(_border)
    .tap(() => _userSend(text));

// A single chat bubble — slides in from the correct side.
Widget _bubble(Msg m) {
  final isUser = m.fromUser;
  return row([
    if (!isUser) _botAvatar(28).pad(right: 8, bottom: 16),
    if (isUser) spacer,
    col([
      label(m.text)
          .size(14)
          .color(_text)
          .pad(h: 14, v: 10)
          .bg(isUser ? _surface2 : _botDeep)
          .round(18)
          .border(
            isUser ? _border : _botGlow,
            radius: 18,
          ),
      gap(3),
      label(_time(m.at))
          .size(10)
          .color(_textDim)
          .alignTo(isUser ? Alignment.centerRight : Alignment.centerLeft),
    ]).maxW(290),
    if (!isUser) spacer,
  ])
      .pad(h: 16, v: 3)
      .animate(isUser ? slide.fromRight : slide.fromLeft)
      .duration(260);
}

// The "thinking" indicator — bot avatar pulses, dots breathe.
Widget _thinkingBubble(double pulse) => row([
      anim(
        pulse,
        builder: (v) => _botAvatar(28).scaleBy(v).pad(right: 8, bottom: 14),
        duration: const Duration(milliseconds: 650),
      ),
      col([
        row([
          _pulseDot(pulse, 0),
          hgap(5),
          _pulseDot(pulse, 1),
          hgap(5),
          _pulseDot(pulse, 2),
        ])
            .pad(h: 16, v: 13)
            .bg(_botDeep)
            .round(18)
            .border(_botGlow, radius: 18),
        gap(3),
        label('Thinking...').size(10).color(_bot),
      ]),
      spacer,
    ]).pad(h: 16, v: 4).animate(fade).duration(200);

// Each dot gets a slightly offset scale so they feel staggered.
Widget _pulseDot(double pulse, int index) {
  // Offset each dot's effective pulse by a phase so they cascade.
  final offsets = [0.0, 0.15, 0.30];
  final effective = ((pulse - 0.82) / 0.30 + offsets[index]).clamp(0.0, 1.0);
  final dotScale = 0.7 + effective * 0.6;

  return anim(
    dotScale,
    builder: (v) => space(7).bg(_bot).round(4).scaleBy(v),
    duration: const Duration(milliseconds: 400),
  );
}

// ── REPLIES ───────────────────────────────────────────────────────────────────

String _reply(String input) {
  final q = input.toLowerCase();

  if (q.contains('vox')) {
    return 'vox is a Flutter framework built around one idea: one import should be enough. '
        'No boilerplate, no BuildContext, no raw widgets — just clean, '
        'flow-based code that reads like what the app does.';
  }
  if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
    return 'Hey! I\'m Aether — an AI assistant built entirely with vox. '
        'One import, full power. What\'s on your mind?';
  }
  if (q.contains('how') && q.contains('work')) {
    return 'This whole app — the chat UI, animations, state, storage — '
        'is powered by vox. The dev wrote one import and got everything else for free.';
  }
  if (q.contains('interesting') || q.contains('tell me')) {
    final facts = [
      'Octopuses have three hearts and blue blood. Two hearts pump blood to the gills; the third pumps it to the body.',
      'The average person walks about 100,000 miles in a lifetime — roughly four times around the Earth.',
      'Honey never spoils. Archaeologists have found 3,000-year-old honey in Egyptian tombs — still edible.',
      'A group of flamingos is called a "flamboyance." A group of crows is called a "murder."',
      'The shortest war in history lasted 38 to 45 minutes — the Anglo-Zanzibar War of 1896.',
    ];
    return facts[input.length % facts.length];
  }
  if (q.contains('color') || q.contains('design') || q.contains('dark') || q.contains('orange')) {
    return 'The palette here is near-pure black with a whisper of green — '
        'almost invisible but it keeps the darkness from feeling flat. '
        'Orange is reserved for me, because warm stands out on dark.';
  }
  if (q.contains('flutter') || q.contains('dart')) {
    return 'Flutter is powerful, but it comes with a lot of ceremony. '
        'vox wraps Flutter so that you write the idea, not the plumbing. '
        'One `col([...])` instead of `Column(children: [...])`. That kind of thing.';
  }
  if (q.contains('who') && (q.contains('you') || q.contains('made'))) {
    return 'I\'m Aether, a demo chatbot built with vox to show what\'s possible '
        'with just one import. In a real app, you\'d wire me to Gemini or any LLM.';
  }

  // Generic fallbacks — rotated by input length so they vary.
  const fallbacks = [
    'Good question. vox was designed so that questions like that don\'t require ten files to answer.',
    'I\'m still learning, but here\'s what I know: vox makes apps that feel like this one surprisingly fast to build.',
    'Honest answer? I\'m a demo bot. But the tech behind me — vox — is very real and very fast.',
    'That\'s worth thinking about. The best tools disappear and let you focus on the idea, not the tool.',
    'Let me put it this way: if building this UI took more than an afternoon, something\'s wrong with the framework.',
  ];
  return fallbacks[input.length % fallbacks.length];
}

// ── UTILS ──────────────────────────────────────────────────────────────────────

String _time(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
