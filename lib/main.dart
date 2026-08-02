import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import 'services/interest_engine.dart';
import 'services/natural_talk.dart';
import 'services/follow_service.dart';
import 'plugins/news_plugin.dart';
import 'providers/ai_config_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TikiTakaApp());
}

class TikiTakaApp extends StatelessWidget {
  const TikiTakaApp({super.key});
  @override Widget build(_) => ChangeNotifierProvider(
    create: (_) => AiConfigProvider(),
    child: MaterialApp(
      title: 'TikiTaka', debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4A574), brightness: Brightness.dark)),
      home: const Home(),
    ),
  );
}

// ─── Card Data ──────────────────────────────────

class CardItem { final String front, back, type; const CardItem(this.front, this.back, {this.type = 'study'}); }

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState() => _HomeState(); }

class _HomeState extends State<Home> {
  final _rng = Random();
  final _flipKey = GlobalKey<FlipCardState>();

  // Services
  final _interest = InterestEngine();
  final _talk = NaturalTalk();
  final _follow = FollowService();
  final _news = NewsPlugin();

  // Card queue
  final List<CardItem> _queue = [];
  int _qIdx = -1;
  int _count = 0, _streak = 0, _total = 0;
  bool _soundOn = true, _requestMode = false;

  // History + timer
  final List<CardItem> _history = [];
  Timer? _autoTimer;
  int _idleCount = 0;
  static const _fib = [5, 8, 13, 21, 34, 55, 89];

  // Built-in data
  static final _studyDecks = <String, List<CardItem>>{
    '영어': [CardItem('apple','사과'),CardItem('book','책'),CardItem('cat','고양이'),CardItem('dog','개'),CardItem('elephant','코끼리'),CardItem('flower','꽃'),CardItem('garden','정원'),CardItem('house','집'),CardItem('ice','얼음'),CardItem('jungle','정글'),CardItem('king','왕'),CardItem('lion','사자'),CardItem('moon','달'),CardItem('night','밤'),CardItem('ocean','바다')],
    '신조어': [CardItem('가심비','가격 대비 심리적 만족도'),CardItem('스불재','스스로 불러온 재앙'),CardItem('중꺾마','중요한 건 꺾이지 않는 마음'),CardItem('킹받다','열 받다'),CardItem('억텐','억지 텐션'),CardItem('점메추','점심 메뉴 추천'),CardItem('소확행','소소하지만 확실한 행복')],
    '수학': [CardItem('E=mc²','에너지=질량×빛²'),CardItem('a²+b²=c²','피타고라스'),CardItem('F=ma','힘=질량×가속도'),CardItem('π≈3.14','원주율'),CardItem('√-1=i','허수 단위')],
    '상식': [CardItem('한글날','10월 9일'),CardItem('독도의 날','10월 25일'),CardItem('광복절','8월 15일'),CardItem('개천절','10월 3일'),CardItem('세계 물의 날','3월 22일')],
  };

  String _activeSubject = '영어';
  static final _allSubjects = ['영어','신조어','수학','상식','유머','뉴스','팔로우'];

  @override void initState() { super.initState(); _loadDeck('영어'); _resetTimer(); }

  int _nextTimeout() => _fib[_idleCount.clamp(0, _fib.length - 1)].clamp(3, 120);

  void _resetTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(Duration(seconds: _nextTimeout()), () {
      if (!mounted || _requestMode) return;
      final s = _flipKey.currentState;
      if (s != null && !s.isFront) { _nextCard(); } else { _idleCount++; s?.toggleCard(); }
      _resetTimer();
    });
  }

  // ─── Deck Loading ─────────────────────────────

  void _loadDeck(String subject) {
    _activeSubject = subject; _queue.clear(); _qIdx = -1; _count = 0; _streak = 0;

    switch (subject) {
      case '뉴스':
        _news.fetch(topic: 'top').then((cards) => setState(() {
          _queue.addAll(cards.map((c) => CardItem(c.title, c.summary, type: 'news')));
        }));
        break;
      case '팔로우':
        for (final person in _follow.all) {
          _queue.add(CardItem('⭐ $person.name', '${person.category} 팔로우 중\n관련 소식이 오면 알려드릴게요.', type: 'follow'));
        }
        if (_queue.isEmpty) _queue.add(CardItem('아직 팔로우한 인물이 없어요.', '▲ "손흥민 팔로우" 라고 요청해보세요.', type: 'guide'));
        break;
      case '유머':
        _queue.addAll([
          CardItem('세상에서 가장 쉬운 AI', '이보다 더 쉬운 AI는 없다.', type: 'humor'),
          CardItem('AI가 먼저 말 걸면?', '사람은 그냥 ○✕ 누르면 됩니다.', type: 'humor'),
          CardItem('코딩 몰라도 만드는 앱', '그게 바로 TikiTaka', type: 'humor'),
        ]);
        // Mix with natural talk
        _queue.insert(0, CardItem(_talk.generate(), '부담 없이 ○✕ 눌러주세요.', type: 'talk'));
        break;
      default:
        final deck = _studyDecks[subject] ?? _studyDecks['영어']!;
        _queue.addAll(deck);
        // Opening card
        _queue.insert(0, CardItem('${subject} 공부를 시작할게요.', '○는 "알아요", ✕는 "몰라요"', type: 'guide'));
    }
    _nextCard();
  }

  void _nextCard() {
    if (_queue.isEmpty) { _loadDeck(_activeSubject); return; }
    _qIdx = (_qIdx + 1) % _queue.length;
    setState(() {});
  }

  CardItem get _current => _queue.isNotEmpty ? _queue[_qIdx] : CardItem('준비 중...', '');

  // ─── Actions ──────────────────────────────────

  void _tap() {
    _idleCount = 0; _autoTimer?.cancel();
    final s = _flipKey.currentState;
    if (s == null) return;
    if (s.isFront) {
      s.toggleCard(); // flip
    } else {
      _count++; _streak++; _total++;
      // Record interest
      _interest.recordInterest(_current.front, true);
      _nextCard();
    }
    _resetTimer();
  }

  void _tapNo() {
    _idleCount = 0; _autoTimer?.cancel();
    final s = _flipKey.currentState;
    if (s == null) return;
    if (s.isFront) {
      s.toggleCard();
    } else {
      _streak = 0; _total++;
      _interest.recordInterest(_current.front, false);
      _nextCard();
    }
    _resetTimer();
  }

  void _goBack() {
    if (_history.isEmpty) return;
    _autoTimer?.cancel();
    final prev = _history.removeLast();
    _queue.insert(0, prev); _qIdx = 0;
    setState(() {}); _resetTimer();
  }

  void _submitRequest(String r) {
    if (r.contains('소리 꺼') || r.contains('음성 꺼') || r.contains('mute')) {
      _soundOn = false; _queue.clear(); _qIdx = 0;
      _queue.add(CardItem('소리를 껐습니다.', '▲ "소리 켜줘"로 다시 켤 수 있어요.', type: 'system'));
    } else if (r.contains('소리 켜') || r.contains('음성 켜')) {
      _soundOn = true; _queue.clear(); _qIdx = 0;
      _queue.add(CardItem('소리를 켰습니다.', '', type: 'system'));
    } else if (r.contains('팔로우') || r.contains('인물')) {
      final name = r.replaceAll(RegExp(r'팔로우|추가|인물'), '').trim();
      if (name.isNotEmpty) {
        _follow.follow('방송문화인', name);
        _queue.clear(); _qIdx = 0;
        _queue.add(CardItem('$name 님을 팔로우했어요.', '이제 관련 소식을 카드로 받아보실 수 있어요.', type: 'follow'));
      }
    } else if (r.contains('뉴스')) {
      _loadDeck('뉴스');
    } else if (_allSubjects.any((s) => r.contains(s))) {
      _loadDeck(_allSubjects.firstWhere((s) => r.contains(s)));
    } else {
      _queue.clear(); _qIdx = 0;
      _queue.add(CardItem('요청을 처리했어요.', r, type: 'system'));
    }
    _requestMode = false;
    setState(() {});
    _resetTimer();
  }

  @override void dispose() { _autoTimer?.cancel(); super.dispose(); }

  // ─── UI ───────────────────────────────────────

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
          front: _cardFace(_current.front, false),
          back: _cardFace(_current.back, true),
          direction: FlipDirection.HORIZONTAL, speed: 400,
        ),
      ))),

    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _btn('✕', const Color(0xFF8B4242), _tapNo),
        _centerBtn(),
        _btn('○', const Color(0xFFD4A574), _tap),
      ])),

    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _allSubjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(label: Text(s, style: TextStyle(color: _activeSubject == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _activeSubject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_activeSubject == s ? 25 : 8)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _loadDeck(s)))).toList())),
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
        decoration: const InputDecoration(hintText: '"뉴스 보여줘" "소리 꺼줘" "손흥민 팔로우"', hintStyle: TextStyle(color: Colors.white24))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.white38))),
        TextButton(onPressed: () { Navigator.pop(ctx); _submitRequest(c.text); },
            child: const Text('전송', style: TextStyle(color: Color(0xFFD4A574)))),
      ],
    ));
  }
}
