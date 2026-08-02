import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  late AnimationController _flipCtrl;
  final _rng = Random();

  final List<String> _following = [];
  List<Map<String,String>> _news = [];

  final List<String> _queue = [];
  int _qIdx = 0;
  String _subject = '영어';
  int _show = 0; // 0=front, 1=flipping, 2=back
  int _cardNum = 0, _goodCount = 0;
  bool _soundOn = true;
  bool _newsTutorialShown = false;

  // Floating button position
  double _btnX = 0, _btnY = 0;

  static const _words = ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다'];
  static const _slang  = ['가심비 가격대비 심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'];
  static const _math  = ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도'];
  static const _facts = ['한글날 10월9일','광복절 8월15일','개천절 10월3일'];
  static const _subjects = ['영어','신조어','수학','상식','유머','뉴스','팔로우'];

  // Card colors
  static const _cardColors = [Color(0xFF2D1B69), Color(0xFF1B3A5C), Color(0xFF3D1A1A), Color(0xFF1A3D2E), Color(0xFF3D2D1A)];
  Color get _cardColor => _cardColors[_cardNum % _cardColors.length];

  @override void initState() {
    super.initState();
    _flipCtrl = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _load('영어');
  }
  @override void dispose() { _flipCtrl.dispose(); super.dispose(); }

  void _load(String s) {
    _subject = s; _queue.clear(); _qIdx = 0; _cardNum = 0; _show = 0; _flipCtrl.reset();

    if (s == '유머') _queue.addAll(['세상에서가장쉬운AI 이보다더쉬운AI는없다','AI가먼저말걸면 사람은그냥OX','코딩몰라도앱만들기 그게TikiTaka']);
    else if (s == '뉴스') { _queue.add('뉴스 불러오는 중...'); _fetchNews(); }
    else if (s == '팔로우') {
      if (_following.isEmpty) _queue.add('팔로우가없어요 ▲손흥민팔로우');
      else for (final f in _following) _queue.add('⭐$f ${f}님소식');
    }
    else if (s == '신조어') _queue.addAll(_slang);
    else if (s == '수학') _queue.addAll(_math);
    else if (s == '상식') _queue.addAll(_facts);
    else _queue.addAll(_words);
    _next();
  }

  void _fetchNews() async {
    try {
      final res = await http.get(Uri.parse('https://feeds.bbci.co.uk/news/rss.xml')).timeout(const Duration(seconds: 10));
      final regex = RegExp(r'<item>.*?<title>(.*?)</title>.*?<description>(.*?)</description>', dotAll: true);
      final matches = regex.allMatches(res.body).take(10).toList();
      _queue.clear(); _qIdx = 0;
      for (final m in matches) {
        final t = m.group(1)?.replaceAll(RegExp(r'<[^>]*>'),'').trim()??'';
        final d = m.group(2)?.replaceAll(RegExp(r'<[^>]*>'),'').replaceAll('&amp;','&').replaceAll('&lt;','<').replaceAll('&gt;','>').trim()??'';
        _queue.add('$t $d');
      }
    } catch (_) { _queue.clear(); _qIdx = 0; _queue.add('인터넷연결확인 뉴스불러오기실패'); }
    if (mounted) setState(() {});
  }

  void _next() {
    if (_queue.isEmpty) { _queue.add('준비중...'); _qIdx = 0; }
    _show = 0; _flipCtrl.reset();
    _qIdx = _rng.nextInt(_queue.length);
    _cardNum++;
    setState(() {});
  }

  String get _cur => _queue.isNotEmpty ? _queue[_qIdx % _queue.length] : '';
  String get _front => _cur.contains(' ') ? _cur.split(' ').first : _cur;
  String get _back => _cur.contains(' ') ? _cur.substring(_cur.indexOf(' ') + 1) : _cur;

  void _sound(String type) {
    if (!_soundOn) return;
    try {
      if (type == 'tak') SystemSound.play(SystemSoundType.click);
      else SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  void _onO() {
    if (_flipCtrl.isAnimating) return;
    if (_show == 0) { _sound('tak'); _flipCtrl.forward(); _show = 2; _goodCount++; } // flip
    else { _next(); }
    setState(() {});
  }

  void _onX() {
    if (_flipCtrl.isAnimating) return;
    if (_show == 0) { _sound('tak'); _flipCtrl.forward(); _show = 2; } // flip
    else { _next(); }
    setState(() {});
  }

  void _request() {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('요청하기', style: TextStyle(color: Color(0xFFD4A574))),
      content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: '"뉴스" "영어" "소리 꺼줘"', hintStyle: TextStyle(color: Colors.white24))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.white38))),
        TextButton(onPressed: () { Navigator.pop(ctx);
          final r = c.text;
          if (r.contains('뉴스')) _load('뉴스');
          else if (r.contains('팔로우')) { _following.add(r.replaceAll('팔로우','').trim()); _load('팔로우'); }
          else if (r.contains('소리 꺼')) { _soundOn = false; _load('유머'); }
          else if (r.contains('소리 켜')) { _soundOn = true; _load('유머'); }
          else if (_subjects.any((s) => r.contains(s))) _load(_subjects.firstWhere((s) => r.contains(s)));
          else _load(_subject);
        }, child: const Text('전송', style: TextStyle(color: Color(0xFFD4A574)))),
      ],
    ));
  }

  @override Widget build(_) => Scaffold(body: SafeArea(child: Stack(children: [
    Column(children: [
      Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16, fontWeight: FontWeight.w700)),
          Text('$_goodCount장', style: const TextStyle(color: Colors.white24, fontSize: 13)),
        ])),

      Expanded(child: Center(child: GestureDetector(
        onTap: _onO,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (w, a) => SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(a),
            child: FadeTransition(opacity: a, child: w)),
          child: _show == 2 ? _card(_back, true) : _card(_front, false),
        ),
      ))),

      Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
          children: _subjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ActionChip(label: Text(s, style: TextStyle(color: _subject == s ? Colors.white : Colors.white38, fontSize: 11)),
              backgroundColor: _subject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
              side: BorderSide(color: Colors.white.withAlpha(_subject == s ? 25 : 8)),
              onPressed: () => _load(s)))).toList())),
      ),
    ]),

    // Floating buttons
    Positioned(
      left: _btnX, bottom: 80 + _btnY,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() { _btnX += d.delta.dx; _btnY -= d.delta.dy; }),
        child: Container(
          width: 100, height: 48,
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A).withAlpha(230), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(20))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            GestureDetector(onTap: _onX, child: Container(width: 30, height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFF8B4242).withAlpha(30)),
              child: const Center(child: Text('✕', style: TextStyle(color: Color(0xFF8B4242), fontSize: 16))))),
            GestureDetector(onTap: _request, child: const Text('▲', style: TextStyle(color: Colors.white24, fontSize: 14))),
            GestureDetector(onTap: _onO, child: Container(width: 30, height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFFD4A574).withAlpha(30)),
              child: const Center(child: Text('○', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16))))),
          ])),
      ),
    ),
  ])));

  Widget _card(String text, bool isBack) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color.lerp(_cardColor, Colors.white, 0.1)!, _cardColor, Color.lerp(_cardColor, Colors.black, 0.3)!]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isBack ? Colors.white.withAlpha(15) : _cardColor.withAlpha(100), width: 1.5),
      boxShadow: [BoxShadow(color: _cardColor.withAlpha(80), blurRadius: 30, offset: const Offset(0, 12))],
    ),
    child: Center(child: Text(text, textAlign: TextAlign.center,
        style: TextStyle(color: isBack ? Colors.white70 : Colors.white,
            fontSize: isBack ? 20 : 28, fontWeight: isBack ? FontWeight.w400 : FontWeight.w600, height: 1.5))),
  );
}
