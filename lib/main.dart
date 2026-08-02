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
  final _ctrlReq = TextEditingController();

  // Decks
  static const _decks = <String, List<String>>{
    '영어': ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다'],
    '신조어': ['가심비 가격대비 심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'],
    '수학': ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도','π≈3.14 원주율','√-1=i 허수단위'],
    '상식': ['한글날 10월9일','독도의날 10월25일','광복절 8월15일','개천절 10월3일','세계물의날 3월22일'],
    '유머': ['세상에서가장쉬운AI 이보다더쉬운AI는없다','AI가먼저말걸면 사람은그냥OX','코딩몰라도만드는앱 그게TikiTaka'],
  };

  String _subject = '영어', _item = '';
  bool _soundOn = true;
  int _cardNum = 0, _fsrsCount = 0;

  static const _subjects = ['영어','신조어','수학','상식','유머'];

  @override void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _nextCard());
  }
  @override void dispose() { _ctrlReq.dispose(); super.dispose(); }

  void _nextCard() {
    final d = _decks[_subject] ?? _decks['영어']!;
    _item = d[_rng.nextInt(d.length)];
    _cardNum++;
    setState(() {});
    // Reset flip
    Future.delayed(const Duration(milliseconds: 100), () {
      try { _flipKey.currentState?.controller?.reset(); } catch (_) {}
    });
    setState(() {});
  }

  void _onFlipDone(bool isFront) {
    if (!isFront) return; // just flipped to back
    // Show back → user taps again → next card
  }

  void _changeSubject(String s) { _subject = s; _cardNum = 0; _nextCard(); }

  void _showRequestCard() {
    _ctrlReq.clear();
    showGeneralDialog(
      context: context, barrierDismissible: true, barrierLabel: '', barrierColor: Colors.black87,
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: Center(
        child: Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1E1E1E), Color(0xFF141414), Color(0xFF0D0D0D)]),
            borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD4A574).withAlpha(40)),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(180), blurRadius: 30, offset: const Offset(0, 12))]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('무엇을 요청하실래요?', style: TextStyle(color: Color(0xFFD4A574), fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            TextField(controller: _ctrlReq, autofocus: true, style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center, decoration: const InputDecoration(border: InputBorder.none,
                hintText: '"소리 꺼줘" "뉴스" "손흥민 팔로우"', hintStyle: TextStyle(color: Colors.white24, fontSize: 14))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _reqBtn('✕ 취소', const Color(0xFF8B4242), () => Navigator.pop(ctx)),
              const SizedBox(width: 16),
              _reqBtn('○ 전송', const Color(0xFFD4A574), () {
                final r = _ctrlReq.text; Navigator.pop(ctx);
                if (r.contains('소리 꺼')) _soundOn = false;
                else if (r.contains('소리 켜')) _soundOn = true;
                else if (_subjects.any((s) => r.contains(s))) _changeSubject(_subjects.firstWhere((s) => r.contains(s)));
              }),
            ]),
          ])),
      ))
    );
  }

  Widget _reqBtn(String label, Color c, VoidCallback fn) => GestureDetector(onTap: fn,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: c.withAlpha(15), border: Border.all(color: c.withAlpha(40))),
      child: Text(label, style: TextStyle(color: c, fontSize: 14))));

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16, fontWeight: FontWeight.w700)),
        Text('#$_cardNum ⏳$_fsrsCount', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),

    // Card — flip_card handles its own tap-to-flip
    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FlipCard(
        key: _flipKey,
        front: _cardFace(_frontText, false),
        back: _cardFace(_backText, true),
        direction: FlipDirection.HORIZONTAL,
        speed: 400,
        onFlipDone: _onFlipDone,
      ))),

    // Buttons
    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(onTap: () => _flipKey.currentState?.toggleCard(), child: _btnW('✕', const Color(0xFF8B4242))),
        GestureDetector(onTap: _showRequestCard, child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(5), border: Border.all(color: Colors.white.withAlpha(10))),
          child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16))))),
        GestureDetector(onTap: () { final s = _flipKey.currentState; if (s != null && !s.isFront) _nextCard(); else s?.toggleCard(); },
            child: _btnW('Ｏ', const Color(0xFFD4A574))),
      ])),

    // Subjects
    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _subjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(label: Text(s, style: TextStyle(color: _subject == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _subject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_subject == s ? 25 : 8)),
            onPressed: () => _changeSubject(s)))).toList())),
    ),
  ])));

  String get _frontText => _item.contains(' ') ? _item.split(' ').first : _item;
  String get _backText => _item.contains(' ') ? _item.substring(_item.indexOf(' ') + 1) : _item;

  Widget _cardFace(String text, bool isBack) => Container(
    decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A1A), Color(0xFF111111), Color(0xFF0A0A0A)]),
      borderRadius: BorderRadius.circular(24), border: Border.all(color: isBack ? Colors.white.withAlpha(12) : const Color(0xFFD4A574).withAlpha(30)),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(160), blurRadius: 24, offset: const Offset(0, 8))]),
    child: Center(child: Padding(padding: const EdgeInsets.all(28),
      child: Text(text, textAlign: TextAlign.center,
          style: TextStyle(color: isBack ? Colors.white54 : Colors.white, fontSize: isBack ? 20 : 28, fontWeight: isBack ? FontWeight.w400 : FontWeight.w600, height: 1.5)))));

  Widget _btnW(String sym, Color c) => Container(width: 64, height: 48,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: c.withAlpha(12), border: Border.all(color: c.withAlpha(30))),
    child: Center(child: Text(sym, style: TextStyle(color: c.withAlpha(220), fontSize: 26))));
}
