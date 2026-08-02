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

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = Random();

  // Deck
  static const _decks = <String, List<String>>{
    '영어': ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다'],
    '신조어': ['가심비 가격대비 심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'],
    '수학': ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도','π≈3.14 원주율','√-1=i 허수단위'],
    '상식': ['한글날 10월9일','독도의날 10월25일','광복절 8월15일','개천절 10월3일','세계물의날 3월22일'],
    '유머': ['세상에서가장쉬운AI 이보다더쉬운AI는없다','AI가먼저말걸면 사람은그냥OX','코딩몰라도만드는앱 그게TikiTaka'],
  };

  String _subject = '영어';
  String _item = '';
  bool _showBack = false;
  int _cardNum = 0;

  static const _subjects = ['영어','신조어','수학','상식','유머'];

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _nextCard();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _nextCard() {
    final deck = _decks[_subject] ?? _decks['영어']!;
    _item = deck[_rng.nextInt(deck.length)];
    _showBack = false;
    _ctrl.reset();
    _cardNum++;
    setState(() {});
  }

  void _flip() {
    if (_showBack) { _nextCard(); return; }
    if (_ctrl.isAnimating) return;
    _ctrl.forward();
    _showBack = true;
    setState(() {});
  }

  void _changeSubject(String s) { _subject = s; _cardNum = 0; _nextCard(); }

  @override Widget build(_) => Scaffold(
    body: SafeArea(child: Column(children: [
      // Header
      Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16, fontWeight: FontWeight.w700)),
          Text('#$_cardNum', style: const TextStyle(color: Colors.white24, fontSize: 13)),
        ])),

      // Card
      Expanded(child: Center(
        child: GestureDetector(
          onTap: _flip,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_ctrl.value * 3.14159),
              child: _ctrl.value < 0.5
                  ? _cardFace(_showBack ? _backText : _frontText, false)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateX(3.14159),
                      child: _cardFace(_backText, true)),
            ),
          ),
        ),
      )),

      // Buttons
      Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: _flip,
            child: Container(width: 64, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFF8B4242).withAlpha(12), border: Border.all(color: const Color(0xFF8B4242).withAlpha(30))),
              child: const Center(child: Text('✕', style: TextStyle(color: Color(0xFF8B4242), fontSize: 24))))),
          GestureDetector(onTap: () {} , child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(5), border: Border.all(color: Colors.white.withAlpha(10))),
            child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16))))),
          GestureDetector(onTap: _flip,
            child: Container(width: 64, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFFD4A574).withAlpha(12), border: Border.all(color: const Color(0xFFD4A574).withAlpha(30))),
              child: const Center(child: Text('○', style: TextStyle(color: Color(0xFFD4A574), fontSize: 24))))),
        ]),
      ),

      // Subjects
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
          children: _subjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(s, style: TextStyle(color: _subject == s ? Colors.white : Colors.white38, fontSize: 11)),
              backgroundColor: _subject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
              side: BorderSide(color: Colors.white.withAlpha(_subject == s ? 25 : 8)),
              onPressed: () => _changeSubject(s),
            ))).toList())),
      ),
    ])),
  );

  String get _frontText => _item.contains(' ') ? _item.split(' ').first : _item;
  String get _backText => _item.contains(' ') ? _item.substring(_item.indexOf(' ') + 1) : _item;

  Widget _cardFace(String text, bool isBack) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
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
}
