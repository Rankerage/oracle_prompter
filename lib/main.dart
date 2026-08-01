import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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

  String _deck = '영어';
  String _front = '', _back = '';
  int _count = 0, _streak = 0;
  bool _flipped = false;
  Timer? _autoTimer;
  final List<_CardHistory> _history = []; // 스와이프용 히스토리
  int _historyIdx = -1;                   // 현재 보고 있는 히스토리 위치

  // Smart timer
  int _idleCount = 0;
  final List<int> _responseMs = [];
  static const _fib = [5, 8, 13, 21, 34, 55, 89];

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    _next(); _resetTimer();
  }

  int _nextTimeout() {
    int base = _fib[_idleCount.clamp(0, _fib.length - 1)];
    if (_responseMs.isNotEmpty) {
      final avgSec = _responseMs.reduce((a,b)=>a+b) / _responseMs.length / 1000;
      if (avgSec > base * 0.7) base = (base * 1.5).round();
      else if (avgSec < base * 0.3) base = (base * 0.7).round();
    }
    return base.clamp(3, 120);
  }

  void _resetTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: _nextTimeout()), () {
      if (!mounted) return;
      if (!_flipped) {
        _idleCount++;
        _ctrl.forward(); setState(() => _flipped = true);
        _resetTimer();
      } else {
        _next(); _resetTimer();
      }
    });
  }

  void _next() {
    final deck = _decks[_deck]!;
    final i = _rng.nextInt(deck.length);
    // Save current to history before moving on
    if (_front.isNotEmpty) {
      _history.add(_CardHistory(front: _front, back: _back, deck: _deck, flipped: _flipped));
      if (_history.length > 50) _history.removeAt(0);
    }
    _historyIdx = -1; // not viewing history
    _flipped = false;
    _front = deck[i].$1; _back = deck[i].$2;
    if (_ctrl.isCompleted) _ctrl.reverse();
    setState(() {});
  }

  void _know(bool known) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _autoTimer?.cancel(); _idleCount = 0;

    if (known) _responseMs.add(800); // approximate click time
    if (_responseMs.length > 20) _responseMs.removeAt(0);

    if (!_flipped) {
      _ctrl.forward(); setState(() => _flipped = true);
    } else {
      if (known) { _count++; _streak++; } else { _streak = 0; }
      _next();
    }
    _resetTimer();
  }

  void _switchDeck(String name) { _deck = name; _count = 0; _streak = 0; _next(); _resetTimer(); }
  void _goBack() {
    if (_history.isEmpty) return;
    _autoTimer?.cancel();
    final prev = _history.removeLast();
    _historyIdx = _history.length;
    _flipped = prev.flipped;
    _front = prev.front; _back = prev.back;
    _deck = prev.deck;
    if (_flipped) _ctrl.forward(); else _ctrl.reverse();
    setState(() {});
    _resetTimer();
  }

  @override void dispose() { _autoTimer?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('🃏 TikiTaka', style: TextStyle(color: const Color(0xFFD4A574).withAlpha(180), fontSize: 16, fontWeight: FontWeight.w700)),
        Text('$_count장${_streak > 2 ? " ★$_streak" : ""}', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),
    const SizedBox(height: 4),

    Expanded(child: Center(child: GestureDetector(
      onTap: () => _know(true),
      onHorizontalDragEnd: (d) { if (d.primaryVelocity != null && d.primaryVelocity! > 300) _goBack(); },
      child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
        transitionBuilder: (w, a) => FadeTransition(opacity: a, child: w),
        child: _card(_flipped ? _back : _front, isBack: _flipped)),
    ))),

    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _btn('✕', const Color(0xFF8B4242), () => _know(false)),
        _centerBtn(),
        _btn('○', const Color(0xFFD4A574), () => _know(true)),
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
    onTap: () {},
    child: Container(width: 40, height: 40, decoration: BoxDecoration(
      shape: BoxShape.circle, color: Colors.white.withAlpha(5),
      border: Border.all(color: Colors.white.withAlpha(10)),
    ), child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16)))));
}

class _CardHistory {
  final String front, back, deck;
  final bool flipped;
  const _CardHistory({required this.front, required this.back, required this.deck, required this.flipped});
}
