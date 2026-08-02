import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/interest_engine.dart';
import 'services/natural_talk.dart';
import 'services/follow_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TikiTakaApp());
}

class TikiTakaApp extends StatelessWidget {
  const TikiTakaApp({super.key});
  @override Widget build(_) => MaterialApp(
    title: 'TikiTaka', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4A574), brightness: Brightness.dark)),
    home: const Home(),
  );
}

class CardData { String front, back; CardData(this.front, this.back); }

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _HomeState(); }

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _rng = Random();
  final _interest = InterestEngine();
  final _follow = FollowService();

  // Animation
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  // Card state
  final List<CardData> _queue = [];
  int _idx = 0;
  bool _isFront = true, _soundOn = true, _requestMode = false;
  String _front = '', _back = '';
  int _count = 0, _total = 0;

  // History
  final List<CardData> _history = [];
  Timer? _autoTimer;
  int _idleCount = 0;
  static const _fib = [5, 8, 13, 21, 34, 55, 89];

  // Decks
  static final _decks = <String, List<CardData>>{
    '영어': [for(var e in [('apple','사과'),('book','책'),('cat','고양이'),('dog','개'),('elephant','코끼리'),('flower','꽃'),('garden','정원'),('house','집'),('ice','얼음'),('jungle','정글'),('king','왕'),('lion','사자'),('moon','달'),('night','밤'),('ocean','바다')]) CardData(e.$1, e.$2)],
    '신조어': [for(var e in [('가심비','가격대비 심리적 만족도'),('스불재','스스로 불러온 재앙'),('중꺾마','중요한건 꺾이지 않는 마음'),('킹받다','열 받다'),('억텐','억지 텐션'),('점메추','점심 메뉴 추천'),('소확행','소소하지만 확실한 행복')]) CardData(e.$1, e.$2)],
    '수학': [for(var e in [('E=mc²','에너지=질량×빛²'),('a²+b²=c²','피타고라스 정리'),('F=ma','힘=질량×가속도'),('π≈3.14','원주율'),('√-1=i','허수 단위')]) CardData(e.$1, e.$2)],
    '상식': [for(var e in [('한글날','10월 9일'),('독도의 날','10월 25일'),('광복절','8월 15일'),('개천절','10월 3일'),('세계 물의 날','3월 22일')]) CardData(e.$1, e.$2)],
  };

  String _subject = '영어';
  static const _subjects = ['영어','신조어','수학','상식','유머','팔로우'];

  @override void initState() {
    super.initState();
    _flipCtrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeOutBack));
    _load('영어');
  }

  @override void dispose() { _autoTimer?.cancel(); _flipCtrl.dispose(); super.dispose(); }

  int _nextTimeout() => _fib[_idleCount.clamp(0, _fib.length - 1)].clamp(3, 120);

  void _resetTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: _nextTimeout()), () {
      if (!mounted || _requestMode || !_isFront) return;
      _idleCount++;
      _flip();
      _resetTimer();
    });
  }

  // ─── Deck ─────────────────────────────────────

  void _load(String s) {
    _subject = s; _queue.clear(); _idx = 0; _count = 0; _isFront = true; _idleCount = 0;
    _flipCtrl.reset();

    switch (s) {
      case '유머':
        _queue.addAll([
          CardData('세상에서 가장 쉬운 AI', '이보다 더 쉬운 AI는 없다.'),
          CardData('AI가 먼저 말 걸면?', '사람은 그냥 ○✕ 누르면 됩니다.'),
          CardData('코딩 몰라도 만드는 앱', '그게 바로 TikiTaka'),
          CardData('사용법: ▲ 누르기', '"소리 꺼줘", "뉴스", "영어 공부"'),
        ]);
        break;
      case '팔로우':
        final people = _follow.all;
        if (people.isEmpty) {
          _queue.add(CardData('아직 팔로우가 없어요.', '▲ "손흥민 팔로우" 라고 요청해보세요.'));
        } else {
          for (final p in people) {
            _queue.add(CardData('⭐ ${p.name}', '${p.category} 팔로우 중'));
          }
        }
        break;
      default:
        final deck = _decks[s] ?? _decks['영어']!;
        _queue.addAll(deck);
    }

    if (_queue.isEmpty) _queue.add(CardData('준비 중...', '잠시만 기다려주세요.'));
    _showCard();
    setState(() {});
    _resetTimer();
  }

  void _showCard() {
    if (_queue.isEmpty) { _load(_subject); return; }
    _idx = _rng.nextInt(_queue.length);
    _front = _queue[_idx].front;
    _back = _queue[_idx].back;
  }

  // ─── 🏓 Flip ──────────────────────────────────

  void _flip() {
    HapticFeedback.lightImpact();
    if (_isFront) {
      SystemSound.play(SystemSoundType.click);
      _flipCtrl.forward();
    } else {
      SystemSound.play(SystemSoundType.alert);
      _flipCtrl.reverse();
    }
    _isFront = !_isFront;
    setState(() {});
  }

  // ─── ○ / ✕ ────────────────────────────────────

  void _onO() {
    _autoTimer?.cancel(); _idleCount = 0;
    if (!_isFront) {
      // Back side: go to next card
      _history.add(CardData(_front, _back));
      if (_history.length > 50) _history.removeAt(0);
      _count++; _total++;
      _interest.recordInterest(_subject, true);
      _showCard();
    }
    // Always flip (or stay flipped to show answer)
    if (_isFront) _flip();
    _resetTimer();
  }

  void _onX() {
    _autoTimer?.cancel(); _idleCount = 0;
    if (!_isFront) {
      // Back side: go to next
      _history.add(CardData(_front, _back));
      if (_history.length > 50) _history.removeAt(0);
      _total++;
      _interest.recordInterest(_subject, false);
      _showCard();
    }
    if (_isFront) _flip();
    _resetTimer();
  }

  // ─── Swipe ────────────────────────────────────

  void _goBack() {
    if (_history.isEmpty) return;
    _autoTimer?.cancel();
    final prev = _history.removeLast();
    _front = prev.front; _back = prev.back;
    _isFront = true; _flipCtrl.reset();
    setState(() {});
    _resetTimer();
  }

  // ─── ▲ Request ────────────────────────────────

  void _submit(String r) {
    if (r.contains('소리 꺼') || r.contains('음성 꺼')) {
      _soundOn = false; _load('유머');
    } else if (r.contains('소리 켜') || r.contains('음성 켜')) {
      _soundOn = true; _load('유머');
    } else if (r.contains('팔로우') || r.contains('인물')) {
      final name = r.replaceAll(RegExp(r'팔로우|추가|인물'), '').trim();
      if (name.isNotEmpty) { _follow.follow('방송문화인', name); }
      _load('팔로우');
    } else if (_subjects.any((s) => r.contains(s))) {
      _load(_subjects.firstWhere((s) => r.contains(s)));
    } else {
      _load(_subject);
    }
    _requestMode = false;
  }

  void _showRequest() {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('요청하기', style: TextStyle(color: Color(0xFFD4A574))),
      content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: '"소리 꺼줘" "뉴스" "손흥민 팔로우"', hintStyle: TextStyle(color: Colors.white24))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.white38))),
        TextButton(onPressed: () { Navigator.pop(ctx); _submit(c.text); },
            child: const Text('전송', style: TextStyle(color: Color(0xFFD4A574)))),
      ],
    ));
  }

  // ─── UI ───────────────────────────────────────

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16, fontWeight: FontWeight.w700)),
        Text('$_count장', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),
    const SizedBox(height: 4),

    // Card area with flip animation
    Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: _onO, // tap card = O
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity != null && d.primaryVelocity! < -300) _goBack();
        },
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (_, __) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(_flipAnim.value * 3.14159),
            child: _flipAnim.value < 0.5
                ? _cardFace(_front, false)
                : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateX(3.14159),
                    child: _cardFace(_back, true)),
          ),
        ),
      ),
    )),

    // Bottom buttons
    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _btn('✕', const Color(0xFF8B4242), _onX),
        _centerBtn(),
        _btn('○', const Color(0xFFD4A574), _onO),
      ])),

    // Subjects
    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _subjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(label: Text(s, style: TextStyle(color: _subject == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _subject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_subject == s ? 25 : 8)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _load(s)))).toList())),
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

  Widget _btn(String sym, Color c, VoidCallback fn) => GestureDetector(onTap: fn,
    child: Container(width: 64, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
      color: c.withAlpha(12), border: Border.all(color: c.withAlpha(30))),
      child: Center(child: Text(sym, style: TextStyle(color: c.withAlpha(220), fontSize: 24)))));

  Widget _centerBtn() => GestureDetector(onTap: _showRequest,
    child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle,
      color: Colors.white.withAlpha(_requestMode ? 12 : 5),
      border: Border.all(color: _requestMode ? const Color(0xFFD4A574).withAlpha(40) : Colors.white.withAlpha(10))),
      child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16)))));
}
