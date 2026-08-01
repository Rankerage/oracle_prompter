import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const TikiTakaApp());

class TikiTakaApp extends StatelessWidget {
  const TikiTakaApp({super.key});
  @override Widget build(_) => MaterialApp(
    title: 'TikiTaka', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4A574), brightness: Brightness.dark)),
    home: const Home(),
  );
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _HomeState(); }

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = Random();

  final _decks = <String, List<(String,String)>>{
    '영어': [('apple','사과'),('book','책'),('cat','고양이'),('dog','개'),('elephant','코끼리'),('flower','꽃'),('garden','정원'),('house','집'),('ice','얼음'),('jungle','정글')],
    '신조어': [('가심비','가격 대비 심리적 만족도'),('스불재','스스로 불러온 재앙'),('중꺾마','중요한 건 꺾이지 않는 마음'),('킹받다','열 받다'),('억텐','억지 텐션')],
    '수학': [('E=mc²','에너지=질량×빛²'),('a²+b²=c²','피타고라스'),('F=ma','힘=질량×가속도')],
    '상식': [('한글날','10월 9일'),('독도의 날','10월 25일'),('광복절','8월 15일'),('개천절','10월 3일')],
    '유머': [('세상에서 가장 쉬운 AI','이보다 더 쉬운 AI는 없다.'),('AI가 먼저 말 걸면?','사람은 그냥 ○✕'),('코딩 몰라도 만드는 앱','그게 TikiTaka')],
  };

  // ─── State ────────────────────────────────────
  String _deck = '영어';
  String _front = '', _back = '';
  int _count = 0, _streak = 0, _total = 0;
  bool _flipped = false;
  bool _ttsOn = true;             // 기본: 음성 ON
  bool _requestMode = false;      // 요청모드 (▲) vs 답변모드 (▼)

  // Tutorial cards interleaved
  int _tutorialIdx = 0;
  static const _tutorials = [
    ('삼각형을 눌러 "소리 꺼줘"라고 요청하면\n음성이 나오지 않습니다.',
     '지금 음성이 나오고 있다면\n▲를 누르고 "소리 꺼줘"라고 말씀하세요.'),
    ('오른쪽으로 스와이프하면\n방금 본 카드를 다시 볼 수 있어요.',
     '👉 오른쪽으로 밀어보세요.\n이전 카드로 돌아갑니다.'),
  ];

  // History
  final List<_CardHistory> _history = [];
  Timer? _autoTimer, _soundTimer;
  int _idleCount = 0;
  static const _fib = [5, 8, 13, 21, 34, 55, 89];

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _next(); _resetTimer();
  }

  // ─── Smart Timer ──────────────────────────────

  int _nextTimeout() {
    int base = _fib[_idleCount.clamp(0, _fib.length - 1)];
    return base.clamp(3, 120);
  }

  void _resetTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: _nextTimeout()), () {
      if (!mounted || _requestMode) return;
      if (!_flipped) { _idleCount++; _flip(); _resetTimer(); }
      else { _next(); _resetTimer(); }
    });
  }

  // ─── Next Card ────────────────────────────────

  void _next() {
    _soundTimer?.cancel();
    if (_front.isNotEmpty) {
      _history.add(_CardHistory(front: _front, back: _back, deck: _deck, flipped: _flipped));
      if (_history.length > 50) _history.removeAt(0);
    }

    // Tutorial every ~8 cards
    if (_total > 0 && _total % 8 == 0 && _tutorialIdx < _tutorials.length) {
      final t = _tutorials[_tutorialIdx];
      _front = t.$1; _back = t.$2; _deck = '사용법';
      _tutorialIdx++;
    } else {
      final deck = _decks[_deck]!;
      final i = _rng.nextInt(deck.length);
      _front = deck[i].$1; _back = deck[i].$2;
    }

    _flipped = false; _total++;
    if (_ctrl.isCompleted) _ctrl.reverse();
    setState(() {});
    _playPingPong(isFlip: false); // 다음카드 나오는 소리
  }

  // ─── Flip ─────────────────────────────────────

  void _flip() {
    _ctrl.forward();
    setState(() => _flipped = true);
    _playPingPong(isFlip: true); // 카드 뒤집히는 소리
  }

  // ─── 🏓 Ping-Pong Sound ───────────────────────

  void _playPingPong({required bool isFlip}) {
    _soundTimer?.cancel();
    // "타" — first hit
    HapticFeedback.lightImpact();
    SystemSound.play(isFlip ? SystemSoundType.click : SystemSoundType.alert);
    // 0.4초 후 "탁" — second hit
    _soundTimer = Timer(const Duration(milliseconds: 400), () {
      HapticFeedback.lightImpact();
      SystemSound.play(isFlip ? SystemSoundType.alert : SystemSoundType.click);
      // 0.3초 후 TTS 시작
      if (_ttsOn && !_requestMode) {
        _soundTimer = Timer(const Duration(milliseconds: 300), () {
          // TTS: 읽기 시작 (flutter_tts로 구현)
        });
      }
    });
  }

  // ─── Tap: O or X ──────────────────────────────

  void _tap() {
    _soundTimer?.cancel(); // 진행 중인 TTS 즉시 중단
    HapticFeedback.lightImpact();
    _idleCount = 0; _autoTimer?.cancel();

    if (!_flipped) {
      _flip();
    } else {
      _next();
    }
    _resetTimer();
  }

  // ─── History (swipe back) ─────────────────────

  void _goBack() {
    if (_history.isEmpty) return;
    _autoTimer?.cancel();
    final prev = _history.removeLast();
    _flipped = prev.flipped; _front = prev.front; _back = prev.back; _deck = prev.deck;
    if (_flipped) _ctrl.forward(); else _ctrl.reverse();
    setState(() {});
    _resetTimer();
  }

  // ─── Request Mode (▲) ─────────────────────────

  void _toggleRequestMode() {
    setState(() => _requestMode = !_requestMode);
    if (!_requestMode) _resetTimer(); // 답변모드로 복귀
  }

  void _submitRequest(String request) {
    _soundTimer?.cancel();
    if (request.contains('소리 꺼') || request.contains('음성 꺼') || request.contains('mute')) {
      _ttsOn = false;
      _front = '음성을 껐습니다.'; _back = '다시 켜시려면 ▲ "소리 켜줘"라고 요청하세요.';
    } else if (request.contains('소리 켜') || request.contains('음성 켜')) {
      _ttsOn = true;
      _front = '음성을 켰습니다.'; _back = '';
    } else if (request.contains('뉴스')) {
      _front = '뉴스 플러그인을 시작합니다.'; _back = '최신 뉴스를 카드로 보여드릴게요.';
    } else {
      _front = '요청을 처리했어요.'; _back = request;
    }
    _deck = '요청';
    _flipped = false;
    _requestMode = false; // 요청 처리 후 자동 복귀
    if (_ctrl.isCompleted) _ctrl.reverse();
    setState(() {});
    _playPingPong(isFlip: false);
    _resetTimer();
  }

  // ─── Subject switch ───────────────────────────

  void _switchDeck(String name) { _deck = name; _count = 0; _streak = 0; _next(); _resetTimer(); }
  @override void dispose() { _soundTimer?.cancel(); _autoTimer?.cancel(); _ctrl.dispose(); super.dispose(); }

  // ─── UI ───────────────────────────────────────

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('🃏 TikiTaka', style: TextStyle(color: const Color(0xFFD4A574).withAlpha(180), fontSize: 16, fontWeight: FontWeight.w700)),
        Text('$_count장${_streak > 2 ? " ★$_streak" : ""}', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),
    const SizedBox(height: 4),

    Expanded(child: Center(child: GestureDetector(
      onTap: _tap,
      onHorizontalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! < -300) _goBack();
      },
      child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
        transitionBuilder: (w, a) => FadeTransition(opacity: a, child: w),
        child: _card(_flipped ? _back : _front, isBack: _flipped)),
    ))),

    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _btn('✕', const Color(0xFF8B4242), _tap),
        _centerBtn(),
        _btn('○', const Color(0xFFD4A574), _tap),
      ])),

    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _decks.keys.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(
            label: Text(s, style: TextStyle(color: _deck == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _deck == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_deck == s ? 25 : 8)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _switchDeck(s),
          ))).toList())),
    ),
  ])));

  Widget _card(String text, {bool isBack = false}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF111111), Color(0xFF0A0A0A)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isBack ? Colors.white.withAlpha(12) : const Color(0xFFD4A574).withAlpha(30)),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(160), blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: Center(child: Text(text, textAlign: TextAlign.center,
        style: TextStyle(color: isBack ? Colors.white54 : Colors.white,
            fontSize: isBack ? 20 : 28, fontWeight: isBack ? FontWeight.w400 : FontWeight.w600, height: 1.5))),
  );

  Widget _btn(String sym, Color color, VoidCallback fn) => GestureDetector(onTap: fn,
    child: Container(width: 64, height: 48, decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: color.withAlpha(12), border: Border.all(color: color.withAlpha(30)),
    ), child: Center(child: Text(sym, style: TextStyle(color: color.withAlpha(220), fontSize: 24)))));

  Widget _centerBtn() => GestureDetector(
    onTap: () => _showRequestDialog(),
    child: Container(width: 40, height: 40, decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withAlpha(_requestMode ? 15 : 5),
      border: Border.all(color: _requestMode ? const Color(0xFFD4A574).withAlpha(40) : Colors.white.withAlpha(10)),
    ), child: Center(child: Text(_requestMode ? '▲' : '▼',
        style: TextStyle(color: _requestMode ? const Color(0xFFD4A574).withAlpha(180) : Colors.white24, fontSize: 16)))));

  void _showRequestDialog() {
    if (_requestMode) { _toggleRequestMode(); return; }
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('요청하기', style: TextStyle(color: Color(0xFFD4A574))),
      content: TextField(controller: ctrl, autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: '"뉴스 보여줘" 또는 "소리 꺼줘"',
            hintStyle: TextStyle(color: Colors.white24))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white38))),
        TextButton(onPressed: () { Navigator.pop(ctx); _submitRequest(ctrl.text); },
            child: const Text('전송', style: TextStyle(color: Color(0xFFD4A574)))),
      ],
    ));
  }
}

class _CardHistory {
  final String front, back, deck;
  final bool flipped;
  const _CardHistory({required this.front, required this.back, required this.deck, required this.flipped});
}
