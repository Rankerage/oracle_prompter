import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const TikiTakaApp());

class TikiTakaApp extends StatelessWidget {
  const TikiTakaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TikiTaka', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4A574), brightness: Brightness.dark)),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _flipped = false;
  int _cardIdx = 0, _count = 0;
  String _front = '', _back = '';
  final _rng = Random();

  final Map<String, List<(String,String)>> _decks = {
    '영어': [for (var e in [('apple','사과'),('book','책'),('cat','고양이'),('dog','개'),('elephant','코끼리'),('flower','꽃'),('garden','정원'),('house','집'),('ice','얼음'),('jungle','정글'),('king','왕'),('lion','사자'),('moon','달'),('night','밤'),('ocean','바다'),('piano','피아노'),('queen','여왕'),('river','강'),('sun','태양'),('tree','나무')]) e],
    '신조어': [for (var e in [('가심비','가격 대비 심리적 만족도'),('스불재','스스로 불러온 재앙'),('중꺾마','중요한 건 꺾이지 않는 마음'),('킹받다','열 받다'),('억텐','억지 텐션'),('점메추','점심 메뉴 추천'),('소확행','소소하지만 확실한 행복'),('갑통알','갑자기 통장을 알려주다')]) e],
    '수학': [for (var e in [('E=mc²','에너지=질량×빛의 속도²'),('a²+b²=c²','피타고라스 정리'),('F=ma','힘=질량×가속도'),('π≈3.14','원주율'),('√-1=i','허수 단위')]) e],
  };

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _pickSubject('영어');
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _pickSubject(String name) {
    setState(() { _flipped = false; _count = 0; });
    _nextCard();
  }

  void _nextCard() {
    final deck = _decks.values.firstWhere((d) => d.isNotEmpty, orElse: () => _decks.values.first);
    _cardIdx = _rng.nextInt(deck.length);
    _front = deck[_cardIdx].$1; _back = deck[_cardIdx].$2;
  }

  void _onTap(bool known) {
    if (!_flipped) { _ctrl.forward(); setState(() => _flipped = true); }
    else {
      if (known) _count++;
      _ctrl.reverse();
      setState(() { _flipped = false; _nextCard(); });
    }
  }

  Widget _card(String text, bool isBack) => Container(width: 300, height: 200,
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1E1E1E), Color(0xFF141414), Color(0xFF0D0D0D)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isBack ? Colors.white.withAlpha(20) : const Color(0xFFD4A574).withAlpha(50)),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(180), blurRadius: 30, offset: const Offset(0, 12)),
        BoxShadow(color: const Color(0xFFD4A574).withAlpha(15), blurRadius: 60, offset: const Offset(0, 8))],
    ),
    child: Center(child: Text(text, textAlign: TextAlign.center,
      style: TextStyle(color: isBack ? Colors.white70 : Colors.white,
        fontSize: isBack ? 22 : 32, fontWeight: isBack ? FontWeight.w400 : FontWeight.w700))),
  );

  Widget _btn(String sym, String label, Color c, VoidCallback fn) => GestureDetector(onTap: fn,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle,
        color: c.withAlpha(20), border: Border.all(color: c.withAlpha(60))),
        child: Center(child: Text(sym, style: TextStyle(color: c, fontSize: 24, fontWeight: FontWeight.w300)))),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.white24, fontSize: 10)),
    ]));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0A0A),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Header
                const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('$_count장 학습 완료', style: TextStyle(color: Colors.white24, fontSize: 13)),
                const SizedBox(height: 24),

                // Card with flip animation
                GestureDetector(
                  onTap: () => _onTap(true),
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(_anim.value * 3.14159),
                      child: _anim.value < 0.5
                          ? _card(_front, false)
                          : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateX(3.14159),
                              child: _card(_back, true)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(_flipped ? '한 번 더 누르면 다음 카드' : '눌러서 뒤집기',
                  style: TextStyle(color: Colors.white12, fontSize: 10)),
                const SizedBox(height: 20),

                // Buttons: ✕ ▲ ○
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _btn('✕', '몰라요', Colors.redAccent.withAlpha(180), () => _onTap(false)),
                  const SizedBox(width: 16),
                  _btn('▲', '명령', Colors.white24, () {}),
                  const SizedBox(width: 16),
                  _btn('○', '알아요', const Color(0xFFD4A574), () => _onTap(true)),
                ]),
                const SizedBox(height: 4),
                const Text('✕ = tiki  |  ○ = taka', style: TextStyle(color: Colors.white12, fontSize: 10)),
                const SizedBox(height: 24),

                // Subject chips
                Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
                  children: _decks.keys.map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    backgroundColor: const Color(0xFF1A1A1A),
                    side: BorderSide(color: Colors.white.withAlpha(12)),
                    onPressed: () => _pickSubject(s),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
