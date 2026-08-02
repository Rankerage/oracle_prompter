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
  late Animation<double> _anim;
  final _rng = Random();

  // card state
  String _front = '', _back = '';
  bool _isFront = true, _soundOn = true;
  int _cardNum = 0, _streak = 0, _total = 0, _correct = 0;

  // leitner boxes
  final List<String> _box1 = [], _box2 = [], _box3 = [], _box4 = [], _box5 = [];
  String _subject = '영어';

  // history
  final List<({String f, String b})> _history = [];

  // idle timer
  Timer? _idle;
  int _idleCount = 0;
  static const _fib = [5, 8, 13, 21, 34, 55, 89];

  static const _decks = <String, List<String>>{
    '영어': ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다'],
    '신조어': ['가심비 가격대비심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'],
    '수학': ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스정리','F=ma 힘=질량×가속도','π≈3.14 원주율'],
    '상식': ['한글날 10월9일','독도의날 10월25일','광복절 8월15일','개천절 10월3일'],
    '유머': ['세상에서가장쉬운AI 이보다더쉬운AI는없다','AI가먼저말걸면 사람은그냥OX','코딩몰라도만드는앱 그게TikiTaka'],
  };
  static const _subjects = ['영어','신조어','수학','상식','유머'];

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _loadSubject('영어');
  }

  void _loadSubject(String s) {
    _subject = s; _box1.clear();_box2.clear();_box3.clear();_box4.clear();_box5.clear();_cardNum=_streak=_total=_correct=0;
    for (final item in _decks[s] ?? _decks['영어']!) { _box1.add(item); }
    _nextCard(); _resetIdle();
  }

  void _nextCard() {
    // Leitner: prefer lower boxes
    final boxes = [_box1, _box2, _box3, _box4, _box5];
    String? pick;
    for (int i = 0; i < boxes.length; i++) {
      if (boxes[i].isNotEmpty && _rng.nextDouble() < 0.7) { pick = boxes[i].removeAt(0); break; }
    }
    pick ??= (_box1.isNotEmpty) ? _box1.removeAt(0) : '준비중...';
    final parts = pick.split(' ');
    _front = parts.first;
    _back = parts.length > 1 ? parts.sublist(1).join(' ') : pick;

    _isFront = true; _cardNum++; _ctrl.reset();
    setState(() {});
  }

  void _promote(String item, int box) {
    final nb = (box + 1).clamp(1, 5);
    switch (nb) { case 1:_box1.add(item);break;case 2:_box2.add(item);break;case 3:_box3.add(item);break;case 4:_box4.add(item);break;case 5:_box5.add(item);break; }
  }

  void _demote(String item) { _box1.add(item); }

  // ─── Actions ──────────────────────────────────

  void _flipToBack() {
    if (!_isFront) return;
    _ctrl.forward();
    _isFront = false; _idleCount = 0;
    setState(() {}); _resetIdle();
  }

  void _o() {
    _idleCount = 0; _resetIdle();
    if (!_isFront) {
      // Back: user knows → promote
      _correct++; _total++; _streak++;
      _history.add((f: _front, b: _back));
      _promote('$_front $_back', 1);
      _nextCard();
      return;
    }
    _flipToBack();
  }

  void _x() {
    _idleCount = 0; _resetIdle();
    if (!_isFront) {
      // Back: user doesn't know → demote
      _total++; _streak = 0;
      _history.add((f: _front, b: _back));
      _demote('$_front $_back');
      _nextCard();
      return;
    }
    _flipToBack();
  }

  void _goBack() {
    if (_history.isEmpty) return;
    final prev = _history.removeLast();
    _front = prev.f; _back = prev.b;
    _isFront = true; _ctrl.reset();
    setState(() {});
  }

  // idle
  void _resetIdle() {
    _idle?.cancel();
    _idle = Timer(Duration(seconds: _fib[_idleCount.clamp(0, _fib.length - 1)]), () {
      if (!mounted) return;
      _idleCount++;
      if (_isFront) { _flipToBack(); _resetIdle(); } else { _nextCard(); _resetIdle(); }
    });
  }

  // ▲
  void _showRequest() {
    final c = TextEditingController();
    showGeneralDialog(context: context, barrierDismissible: true, barrierLabel: '', barrierColor: Colors.black87,
      pageBuilder: (_,__,___) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, __) => FadeTransition(opacity: anim, child: Center(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E1E), Color(0xFF141414), Color(0xFF0D0D0D)]),
          borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD4A574).withAlpha(40)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(180), blurRadius: 30, offset: const Offset(0, 12))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('무엇을 요청하실래요?', style: TextStyle(color: Color(0xFFD4A574), fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center, decoration: const InputDecoration(border: InputBorder.none,
              hintText: '"소리 꺼줘" "뉴스" "수학"', hintStyle: TextStyle(color: Colors.white24, fontSize: 14))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _rBtn('✕ 취소', const Color(0xFF8B4242), () => Navigator.pop(ctx)),
            const SizedBox(width: 16),
            _rBtn('○ 전송', const Color(0xFFD4A574), () {
              final r = c.text; Navigator.pop(ctx);
              if (r.contains('소리 꺼')) _soundOn = false;
              else if (r.contains('소리 켜')) _soundOn = true;
              else if (_subjects.any((s) => r.contains(s))) _loadSubject(_subjects.firstWhere((s) => r.contains(s)));
            }),
          ]),
        ])))));
  }

  Widget _rBtn(String l, Color c, VoidCallback f) => GestureDetector(
    onTap: f,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        color: c.withAlpha(15), border: Border.all(color: c.withAlpha(40))),
      child: Text(l, style: TextStyle(color: c, fontSize: 14)),
    ),
  );

  @override void dispose() { _idle?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16, fontWeight: FontWeight.w700)),
        Text('#$_cardNum ✅$_correct/$_total', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),

    Expanded(child: Center(child: GestureDetector(
      onHorizontalDragEnd: (d) { if (d.primaryVelocity != null && d.primaryVelocity! < -300) _goBack(); },
      child: AnimatedBuilder(animation: _anim, builder: (_, __) => Transform(alignment: Alignment.center,
        transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(_anim.value * 3.14159),
        child: _anim.value < 0.5
            ? _card(_front, false)
            : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateX(3.14159), child: _card(_back, true))))))),

    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _btn('✕', const Color(0xFF8B4242), _x),
        GestureDetector(onTap: _showRequest, child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(5), border: Border.all(color: Colors.white.withAlpha(10))),
          child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16))))),
        _btn('Ｏ', const Color(0xFFD4A574), _o),
      ])),

    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _subjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(label: Text(s, style: TextStyle(color: _subject == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _subject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_subject == s ? 25 : 8)),
            onPressed: () => _loadSubject(s)))).toList())),
    ),
  ])));

  Widget _card(String t, bool b) => Container(margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(28), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A1A), Color(0xFF111111), Color(0xFF0A0A0A)]),
      borderRadius: BorderRadius.circular(24), border: Border.all(color: b ? Colors.white.withAlpha(12) : const Color(0xFFD4A574).withAlpha(30)),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(160), blurRadius: 24, offset: const Offset(0, 8))]),
    child: Center(child: Text(t, textAlign: TextAlign.center, style: TextStyle(color: b ? Colors.white54 : Colors.white, fontSize: 28, fontWeight: FontWeight.w600, height: 1.5))));

  Widget _btn(String s, Color c, VoidCallback f) => GestureDetector(onTap: f,
    child: Container(width: 64, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: c.withAlpha(12), border: Border.all(color: c.withAlpha(30))),
      child: Center(child: Text(s, style: TextStyle(color: c.withAlpha(220), fontSize: 26)))));
}
