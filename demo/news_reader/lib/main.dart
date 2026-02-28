import 'package:vox/vox.dart';

// ── THEME ────────────────────────────────────────────────────────────────────

const _ink     = Color(0xFF0A0C14);
const _card    = Color(0xFF131620);
const _card2   = Color(0xFF1C1F2E);
const _accent  = Color(0xFF4F8EF7);
const _accentG = Color(0xFF6FA8FF);
const _text    = Color(0xFFF2F4FF);
const _textDim = Color(0xFF6B7280);
const _tagBg   = Color(0xFF1E2340);

// ── ENTRY ────────────────────────────────────────────────────────────────────

void main() => voxApp(
      theme: const VoxTheme(
        primary:    _accent,
        background: _ink,
        surface:    _card,
        text:       _text,
        radius:     14,
        dark: VoxTheme(primary: _accent, background: _ink, surface: _card,
            text: _text, radius: 14),
      ),
      init: _boot,
      home: SplashScreen(),
    );

// ── DATA MODELS ───────────────────────────────────────────────────────────────

class Article extends VoxModel {
  final String id, title, summary, imageUrl, source, category;
  final DateTime publishedAt;
  final int readMins;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedAt,
    this.readMins = 3,
  });

  @override
  Article decode(Map<String, dynamic> j) => Article(
        id:          j.str('id'),
        title:       j.str('title'),
        summary:     j.str('summary'),
        imageUrl:    j.str('imageUrl'),
        source:      j.str('source'),
        category:    j.str('category'),
        publishedAt: j.date('publishedAt'),
        readMins:    j.n('readMins', 3),
      );

  @override
  Map<String, dynamic> encode() => {
        'id':          id,
        'title':       title,
        'summary':     summary,
        'imageUrl':    imageUrl,
        'source':      source,
        'category':    category,
        'publishedAt': publishedAt.toIso8601String(),
        'readMins':    readMins,
      };
}

// ── DATA SOURCES ──────────────────────────────────────────────────────────────

final _articles      = state(<Article>[]);
final _bookmarks     = state(<String>{});
final _activeCategory = state('All');
final _isLoading     = state(true);

Future<void> _boot() async {
  final saved = await load('bookmarks');
  if (saved is List) {
    _bookmarks.set(Set<String>.from(saved.whereType<String>()));
  }
  await _fetchFeed();
}

Future<void> _fetchFeed() async {
  _isLoading.set(true);
  await Future<void>.delayed(const Duration(milliseconds: 900));
  _articles.set(_mockArticles());
  _isLoading.set(false);
}

// ── DATA ACTIONS ──────────────────────────────────────────────────────────────

Future<void> _toggleBookmark(String id) async {
  final current = Set<String>.from(_bookmarks.peek);
  current.contains(id) ? current.remove(id) : current.add(id);
  _bookmarks.set(current);
  await save('bookmarks', current.toList());
}

// ── SCREENS ───────────────────────────────────────────────────────────────────

class SplashScreen extends VoxScreen {
  @override
  void ready() => delay(const Duration(milliseconds: 2200),
      () => go(HomeScreen(), replace: true));

  @override
  Widget get view => scaffold(
        safe(col([
          _brandLogo().animate(scale).duration(500),
          gap(32),
          label('made with').size(12).color(_textDim).letterSpacing(1),
          gap(8),
          _wordmark().animate(scale).duration(600),
          gap(8),
          label('one import. full power.').size(11).color(_textDim).letterSpacing(0.5),
        ]).centered.center),
        bg: _ink,
      );
}

class HomeScreen extends VoxScreen {
  @override
  Widget get view {
    final all         = _articles.val;
    final loading     = _isLoading.val;
    final cat         = _activeCategory.val;
    final bookmarkIds = _bookmarks.val;

    final filtered = cat == 'All'
        ? all
        : all.where((a) => a.category == cat).toList();

    return scaffold(
      safe(col([
        _topBar(),
        _categoryRow(cat),
        gap(4),
        toggle(
          loading,
          loader(size: 32, color: _accent).center.expand,
          _feed(filtered, bookmarkIds),
        ),
      ]).stretched),
      bg:     _ink,
      drawer: _appDrawer(),
    );
  }
}

class ArticleScreen extends VoxScreen {
  final Article article;
  ArticleScreen(this.article);

  @override
  Widget get view {
    final bookmarked = _bookmarks.val.contains(article.id);

    return scaffold(
      col([
        img(article.imageUrl, height: 260, fit: BoxFit.cover)
            .hero(article.id),
        col([
          gap(20),
          row([
            _tagChip(article.category),
            spacer,
            label('${article.readMins} min read').size(12).color(_textDim),
          ]).pad(h: 20),
          gap(12),
          label(article.title).heavy.size(22).color(_text).pad(h: 20),
          gap(8),
          row([
            label(article.source).semibold.size(13).color(_accent),
            hgap(8),
            label('·').size(13).color(_textDim),
            hgap(8),
            label(_timeAgo(article.publishedAt)).size(12).color(_textDim),
          ]).pad(h: 20),
          gap(16),
          divider.pad(h: 20),
          gap(16),
          label(article.summary).size(15).color(_text).pad(h: 20),
          gap(12),
          label(_loremBody).size(15).color(_textDim).pad(h: 20),
          gap(40),
        ]).scrollable.expand,
      ]),
      bg: _ink,
      fab: fab(
        bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        () => _toggleBookmark(article.id),
        color:     bookmarked ? _accent : _card2,
        iconColor: bookmarked ? Colors.white : _textDim,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

Widget _brandLogo() => card(
      icon(Icons.newspaper_rounded, color: _accent, size: 36)
          .center.sized(80, 80),
      color:       const Color(0x264F8EF7),
      borderColor: const Color(0x604F8EF7),
      radius: 24,
    );

Widget _wordmark() => row([
      label('v').heavy.size(46).color(_accent),
      label('o').heavy.size(46).color(_accentG),
      label('x').heavy.size(46).color(_accent),
    ]);

Widget _topBar() => row([
      col([
        label('The Pulse').heavy.size(20).color(_text),
        label('Stay informed').size(11).color(_textDim),
      ]).left.expand,
      icon(Icons.refresh_rounded, color: _textDim, size: 22)
          .pad(all: 10)
          .tap(_fetchFeed),
    ]).pad(h: 16, v: 12);

Widget _categoryRow(String active) => hscroll([
      for (var i = 0; i < _categories.length; i++) ...[
        _categoryChip(_categories[i], _categories[i] == active),
        if (i < _categories.length - 1) hgap(8),
      ],
    ], padH: 16, padBottom: 8);

Widget _categoryChip(String text, bool active) =>
    label(text)
        .size(13)
        .semibold
        .color(active ? Colors.white : _textDim)
        .pad(h: 14, v: 8)
        .bg(active ? _accent : _tagBg)
        .round(20)
        .tap(() => _activeCategory.set(text));

Widget _feed(List<Article> articles, Set<String> bookmarkIds) {
  if (articles.isEmpty) {
    return col([
      gap(60),
      icon(Icons.newspaper_rounded, color: _textDim, size: 48).center.animate(scale),
      gap(16),
      label('Nothing here').bold.size(16).color(_text).center,
      gap(6),
      label('Try a different category').size(13).color(_textDim).center,
    ]).expand;
  }

  final featured = articles.first;
  final rest     = articles.skip(1).toList();

  return col([
    _featuredCard(featured, bookmarkIds.contains(featured.id))
        .pad(h: 16, bottom: 12)
        .animate(slide.fromBottom).duration(300),
    ...rest.asMap().entries.map(
          (e) => _articleCard(e.value, bookmarkIds.contains(e.value.id), e.key + 1)),
    gap(30),
  ]).scrollable.expand;
}

Widget _featuredCard(Article a, bool bookmarked) => card(
      col([
        img(a.imageUrl, height: 200, fit: BoxFit.cover)
            .hero(a.id).round(10),
        gap(12),
        row([_tagChip(a.category), spacer,
            label('${a.readMins} min').size(11).color(_textDim)]),
        gap(8),
        label(a.title).bold.size(18).color(_text).maxLines(2).ellipsis,
        gap(6),
        label(a.summary).size(13).color(_textDim).maxLines(2).ellipsis,
        gap(10),
        row([
          label(a.source).semibold.size(12).color(_accent),
          spacer,
          label(_timeAgo(a.publishedAt)).size(11).color(_textDim),
        ]),
      ]).pad(all: 14),
      color: _card,
      radius: 16,
      borderColor: const Color(0x1A4F8EF7),
    ).tap(() => go(ArticleScreen(a)));

Widget _articleCard(Article a, bool bookmarked, int i) => card(
      row([
        img(a.imageUrl, width: 86, height: 86, fit: BoxFit.cover)
            .hero('${a.id}_sm').round(10),
        hgap(12),
        col([
          _tagChip(a.category),
          gap(6),
          label(a.title).semibold.size(14).color(_text).maxLines(2).ellipsis,
          gap(4),
          row([
            label(a.source).size(11).color(_accent),
            spacer,
            label(_timeAgo(a.publishedAt)).size(11).color(_textDim),
          ]),
        ]).left.expand,
        hgap(4),
        icon(
          bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: bookmarked ? _accent : _textDim,
          size: 18,
        ).tap(() => _toggleBookmark(a.id)),
      ]).pad(all: 12),
      color: _card,
      radius: 14,
      borderColor: const Color(0x0F4F8EF7),
    )
        .pad(h: 16, bottom: 10)
        .tap(() => go(ArticleScreen(a)))
        .animate(slide.fromBottom)
        .duration(300 + i * 50);

Widget _appDrawer() => Drawer(
      backgroundColor: _card,
      child: safe(col([
        gap(20),
        row([
          card(
            icon(Icons.newspaper_rounded, color: _accent, size: 22)
                .center.sized(44, 44),
            color: const Color(0x264F8EF7), radius: 14,
          ),
          hgap(12),
          col([
            label('The Pulse').heavy.size(17).color(_text),
            label('News Reader').size(12).color(_textDim),
          ]).left,
        ]).pad(h: 20),
        gap(20),
        divider.pad(h: 20),
        gap(8),
        _drawerRow(Icons.home_rounded,           'Home'),
        _drawerRow(Icons.bookmark_rounded,        'Bookmarks'),
        _drawerRow(Icons.explore_rounded,         'Explore'),
        _drawerRow(Icons.notifications_rounded,   'Alerts'),
        _drawerRow(Icons.settings_rounded,        'Settings'),
        gap(8),
        divider.pad(h: 20),
        gap(12),
        card(
          col([
            row([
              icon(Icons.bolt_rounded, color: _accent, size: 16),
              hgap(8),
              label('Built with vox').semibold.size(13).color(_text),
            ]),
            gap(4),
            label('v0.5.0  ·  pub.dev/packages/vox').size(11).color(_textDim),
          ]).left.pad(all: 14),
          color: const Color(0x1A4F8EF7),
          borderColor: const Color(0x334F8EF7),
          radius: 12,
        ).pad(h: 20),
      ]).left.scrollable),
    );

Widget _drawerRow(IconData ico, String title) =>
    row([
      icon(ico, color: _textDim, size: 20),
      hgap(14),
      label(title).size(15).color(_text),
    ]).pad(h: 20, v: 14);

Widget _tagChip(String text) =>
    label(text).size(11).semibold.color(_accent)
        .pad(h: 8, v: 4)
        .bg(const Color(0x264F8EF7))
        .round(6);

// ── CONSTANTS / MOCK DATA ─────────────────────────────────────────────────────

const _categories = ['All', 'Tech', 'Science', 'Business', 'Design', 'Health'];

const _loremBody =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim '
    'veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea '
    'commodo consequat.\n\n'
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
    'dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non '
    'proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

List<Article> _mockArticles() => [
      Article(id: '1', category: 'Tech',
        title: 'The Future of AI: How Large Language Models Are Reshaping Software',
        summary: 'Developers everywhere are rethinking how they write code as AI copilots become standard tools.',
        imageUrl: 'https://picsum.photos/seed/tech1/600/400',
        source: 'Tech Insider',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)), readMins: 5),
      Article(id: '2', category: 'Science',
        title: 'Webb Telescope Reveals Galaxies Older Than Previously Thought',
        summary: 'New imagery pushes back the formation date of mature galaxies by hundreds of millions of years.',
        imageUrl: 'https://picsum.photos/seed/space2/600/400',
        source: 'Space Daily',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)), readMins: 4),
      Article(id: '3', category: 'Design',
        title: 'Why Micro-interactions Are the Secret Sauce of Memorable UX',
        summary: 'Small animations create the difference between apps users tolerate and ones they love.',
        imageUrl: 'https://picsum.photos/seed/design3/600/400',
        source: 'UX Collective',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)), readMins: 3),
      Article(id: '4', category: 'Business',
        title: 'Startup Funding Falls 30% as Investors Tighten Requirements',
        summary: 'VC firms are now demanding stronger unit economics before committing early-stage rounds.',
        imageUrl: 'https://picsum.photos/seed/biz4/600/400',
        source: 'Financial View',
        publishedAt: DateTime.now().subtract(const Duration(hours: 7)), readMins: 6),
      Article(id: '5', category: 'Health',
        title: 'Sleep Quality Over Quantity: New Research Reframes the 8-Hour Rule',
        summary: 'Scientists find deep sleep stages matter far more than raw hours for cognitive performance.',
        imageUrl: 'https://picsum.photos/seed/health5/600/400',
        source: 'Wellness Today',
        publishedAt: DateTime.now().subtract(const Duration(hours: 9)), readMins: 4),
      Article(id: '6', category: 'Tech',
        title: 'Flutter 4.0 Lands with Wasm Compilation and Hot Reload for Web',
        summary: 'Google doubles down on cross-platform with a faster rendering engine.',
        imageUrl: 'https://picsum.photos/seed/flutter6/600/400',
        source: 'Dev Weekly',
        publishedAt: DateTime.now().subtract(const Duration(hours: 11)), readMins: 5),
      Article(id: '7', category: 'Science',
        title: 'Researchers Achieve Breakthrough in Room-Temperature Superconductors',
        summary: 'A South Korea team reports stable superconductivity at 22°C.',
        imageUrl: 'https://picsum.photos/seed/science7/600/400',
        source: 'Nature Brief',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)), readMins: 7),
    ];

// ── UTILS ─────────────────────────────────────────────────────────────────────

String _timeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours   < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
