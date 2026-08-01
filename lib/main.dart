import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

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

class _HomeState extends State<Home> {
  final _rng = Random();
  final _flipKey = GlobalKey<FlipCardState>();

  final _decks = <String, List<(String,String)>>{
    '영어': [('apple','사과'),('book','책'),('cat','고양이'),('dog','개'),('elephant','코끼리'),('flower','꽃'),('garden','정원'),('house','집'),('ice','얼음'),('jungle','정글')],
    '신조어': [('가심비','가격 대비 심리적 만족도'),('스불재','스스로 불러온 재앙'),('중꺾마','중요한 건 꺾이지 않는 마음'),('킹받다','열 받다'),('억텐','억지 텐션')],
    '수학': [('E=mc²','에너지=질량×빛²'),('a²+b²=c²','피타고라스'),('F=ma','힘=질량×가속도')],
    '상식': [('한글날','10월 9일'),('독도의 날','10월 25일'),('광복절','8월 15일'),('개천절','10월 3일')],
    '유머': [('세상에서 가장 쉬운 AI','이보다 더 쉬운 AI는 없다.'),('AI가 먼저 말 걸면?','사람은 그냥 ○✕'),('코딩 몰라도 만드는 앱','그게 TikiTaka')],
  };

  String _deck = '영어';
  String _front = '', _back = '';
  int _count = 0, _streak = 0, _total = 0;
  bool _soundOn = true;
  bool _requestMode = false;

  int _tutorialIdx = 0;
  static const _tutorials = [
    ('▲ "소리 꺼줘" → 음성+효과음 모두 중지',
     '다시 켜시려면 ▲ "소리 켜줘"'),
    ('👉 오른쪽 스와이프 → 이전 카드',
     '방금 본 카드를 다시 봅니다.'),
  ];

  final List<_CardHistory> _history = [];
  Timer? _autoTimer;
  int _idleCount = 0;
  static const _fib = [5, 8, 13, 21, 34, 55, 89];

  @override void initState() {
    super.initState(); _next(); _resetTimer();
  }

  int _nextTimeout() => _fib[_idleCount.clamp(0, _fib.length - 1)].clamp(3, 120);

  void _resetTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: _nextTimeout()), () {
      if (!mounted || _requestMode) return;
      final state = _flipKey.currentState;
      if (state != null && !state.isFront) { _next(); } else { _idleCount++; state?.toggleCard(); }
      _resetTimer();
    });
  }

  void _next() {
    if (_front.isNotEmpty) {
      _history.add(_CardHistory(f: _front, b: _back, d: _deck));
      if (_history.length > 50) _history.removeAt(0);
    }

    if (_total > 0 && _total % 8 == 0 && _tutorialIdx < _tutorials.length) {
      final t = _tutorials[_tutorialIdx]; _front = t.$1; _back = t.$2; _deck = '사용법'; _tutorialIdx++;
    } else {
      final deck = _decks[_deck]!; final i = _rng.nextInt(deck.length);
      _front = deck[i].$1; _back = deck[i].$2;
    }
    _total++;
    _flipKey.currentState?.controller?.reset();
    setState(() {});
  }

  void _tap() {
    _idleCount = 0; _autoTimer?.cancel();
    final state = _flipKey.currentState;
    if (state == null) return;
    if (state.isFront) {
      state.toggleCard(); // flip → "다닥"
    } else {
      _next(); // next card → "타탁"
    }
    _resetTimer();
  }

  void _goBack() {
    if (_history.isEmpty) return;
    _autoTimer?.cancel();
    final prev = _history.removeLast();
    _front = prev.f; _back = prev.b; _deck = prev.d;
    setState(() {}); _resetTimer();
  }

  void _submitRequest(String r) {
    if (r.contains('소리 꺼') || r.contains('음성 꺼') || r.contains('mute')) {
      _soundOn = false; _front = '소리를 껐습니다.'; _back = '▲ "소리 켜줘"로 다시 켤 수 있어요.';
    } else if (r.contains('소리 켜') || r.contains('음성 켜')) {
      _soundOn = true; _front = '소리를 켰습니다.'; _back = '';
    } else if (r.contains('뉴스')) {
      _front = '뉴스 플러그인을 시작합니다.'; _back = '최신 뉴스를 카드로 보여드릴게요.';
    } else {
      _front = '요청을 처리했어요.'; _back = r;
    }
    _deck = '요청'; _requestMode = false;
    setState(() {}); _resetTimer();
  }

  void _switchDeck(String n) { _deck = n; _count = 0; _streak = 0; _next(); _resetTimer(); }
  @override void dispose() { _autoTimer?.cancel(); super.dispose(); }

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('🃏 TikiTaka', style: TextStyle(color: const Color(0xFFD4A574).withAlpha(180), fontSize: 16, fontWeight: FontWeight.w700)),
        Text('$_count장${_streak > 2 ? " ★$_streak" : ""}', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),
    const SizedBox(height: 4),

    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onHorizontalDragEnd: (d) { if (d.primaryVelocity != null && d.primaryVelocity! < -300) _goBack(); },
        child: FlipCard(
          key: _flipKey,
          front: _cardFace(_front, false),
          back: _cardFace(_back, true),
          direction: FlipDirection.HORIZONTAL,
          speed: 400,
        ),
      ))),

    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _btn('✕', const Color(0xFF8B4242)),
        _centerBtn(),
        _btn('○', const Color(0xFFD4A574)),
      ])),

    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _decks.keys.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(label: Text(s, style: TextStyle(color: _deck == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _deck == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_deck == s ? 25 : 8)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _switchDeck(s)))).toList())),
    ),
  ])));

  Widget _cardFace(String text, bool isBack) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF111111), Color(0xFF0A0A0A)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isBack ? Colors.white.withAlpha(12) : const Color(0xFFD4A574).withAlpha(30)),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(160), blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: Center(child: Padding(padding: const EdgeInsets.all(28),
      child: Text(text, textAlign: TextAlign.center,
          style: TextStyle(color: isBack ? Colors.white54 : Colors.white,
              fontSize: isBack ? 20 : 28, fontWeight: isBack ? FontWeight.w400 : FontWeight.w600, height: 1.5)))),
  );

  Widget _btn(String sym, Color c) => GestureDetector(onTap: _tap,
    child: Container(width: 64, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
      color: c.withAlpha(12), border: Border.all(color: c.withAlpha(30))),
      child: Center(child: Text(sym, style: TextStyle(color: c.withAlpha(220), fontSize: 24)))));

  Widget _centerBtn() => GestureDetector(onTap: () => _showRequest(),
    child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle,
      color: Colors.white.withAlpha(_requestMode ? 12 : 5),
      border: Border.all(color: _requestMode ? const Color(0xFFD4A574).withAlpha(40) : Colors.white.withAlpha(10))),
      child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16)))));

  void _showRequest() {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('요청하기', style: TextStyle(color: Color(0xFFD4A574))),
      content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: '"뉴스 보여줘" "소리 꺼줘"', hintStyle: TextStyle(color: Colors.white24))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.white38))),
        TextButton(onPressed: () { Navigator.pop(ctx); _submitRequest(c.text); },
            child: const Text('전송', style: TextStyle(color: Color(0xFFD4A574)))),
      ],
    ));
  }
}

class _CardHistory {
  final String f, b, d;
  const _CardHistory({required this.f, required this.b, required this.d});
}
