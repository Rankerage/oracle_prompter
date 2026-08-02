import 'dart:async';
import 'dart:math';
import 'dart:convert';
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
  late AnimationController _ctrl;
  final _rng = Random();

  // Follow list
  final List<String> _following = [];
  // News cache
  List<Map<String,String>> _news = [];

  // Card data — single string: "front|back"
  final List<String> _queue = [];
  int _qIdx = 0;
  String _subject = '영어';
  bool _showBack = false;
  int _cardNum = 0, _goodCount = 0;
  bool _soundOn = true;

  // Decks
  static const _words = ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다','piano 피아노','queen 여왕','river 강','sun 태양','tree 나무'];
  static const _slang  = ['가심비 가격대비심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'];
  static const _math  = ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도'];
  static const _facts = ['한글날 10월9일','광복절 8월15일','개천절 10월3일'];
  static const _subjects = ['영어','신조어','수학','상식','유머','뉴스','팔로우'];

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _load('영어');
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  // ─── Deck loading ─────────────────────────────

  void _load(String s) {
    _subject = s; _queue.clear(); _qIdx = 0; _cardNum = 0; _showBack = false; _ctrl.reset();

    if (s == '유머') {
      _queue.addAll(['세상에서 가장 쉬운 AI 이보다 더 쉬운 AI는 없다.','AI가 먼저 말 걸면? 사람은 그냥 ○✕','코딩 몰라도 만드는 앱 그게 바로 TikiTaka']);
    } else if (s == '뉴스') {
      _queue.add('뉴스 불러오는 중... 잠시만 기다려주세요.');
      _fetchNews();
    } else if (s == '팔로우') {
      if (_following.isEmpty) _queue.add('아직 팔로우가 없어요. ▲ "손흥민 팔로우"');
      else for (final f in _following) _queue.add('⭐ $f ${f}님의 최신 소식을 기다리는 중');
    } else if (s == '신조어') {
      _queue.addAll(_slang);
    } else if (s == '수학') {
      _queue.addAll(_math);
    } else if (s == '상식') {
      _queue.addAll(_facts);
    } else {
      _queue.addAll(_words);
    }
    _showCurrent();
  }

  void _fetchNews() async {
    try {
      final res = await http.get(Uri.parse('https://feeds.bbci.co.uk/news/rss.xml')).timeout(const Duration(seconds: 10));
      final body = res.body;
      final regex = RegExp(r'<item>.*?<title>(.*?)</title>.*?<description>(.*?)</description>', dotAll: true);
      final matches = regex.allMatches(body).take(10).toList();
      _news.clear();
      _queue.clear(); _qIdx = 0;
      for (final m in matches) {
        final title = m.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? '';
        final desc = m.group(2)?.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&amp;','&').replaceAll('&lt;','<').replaceAll('&gt;','>').trim() ?? '';
        _news.add({'title': title, 'desc': desc});
        _queue.add('$title $desc');
      }
    } catch (_) {
      _queue.clear(); _qIdx = 0;
      _queue.addAll(['인터넷 연결을 확인해주세요. 뉴스를 불러올 수 없어요.','잠시 후 다시 시도해주세요.']);
      _news.clear();
    }
    if (mounted) setState(() {});
  }

  void _showCurrent() {
    if (_queue.isEmpty) { _queue.add('준비 중...'); _qIdx = 0; }
    _showBack = false; _ctrl.reset();
    _qIdx = _rng.nextInt(_queue.length);
    _cardNum++;
    setState(() {});
  }

  String get _frontText => _current.contains(' ') ? _current.split(' ').first : _current;
  String get _backText => _current.contains(' ') ? _current.substring(_current.indexOf(' ') + 1) : _current;
  String get _current => _queue.isNotEmpty ? _queue[_qIdx % _queue.length] : '';

  // ─── Actions ──────────────────────────────────

  void _flip() {
    if (_ctrl.isAnimating) return;
    if (_showBack) { _showCurrent(); return; }
    if (_soundOn) try { SystemSound.play(SystemSoundType.click); } catch (_) {}
    _ctrl.forward(); _showBack = true; _goodCount++;
    setState(() {});
  }

  void _skip() {
    if (_ctrl.isAnimating) return;
    if (_showBack) { _showCurrent(); return; }
    if (_soundOn) try { SystemSound.play(SystemSoundType.alert); } catch (_) {}
    _ctrl.forward(); _showBack = true;
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
        TextButton(onPressed: () {
          Navigator.pop(ctx);
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

  // ─── UI ───────────────────────────────────────

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('🃏 TikiTaka', style: TextStyle(color: Color(0xFFD4A574), fontSize: 16, fontWeight: FontWeight.w700)),
        Text(_soundOn ? '$_goodCount장' : '$_goodCount장 🔇', style: const TextStyle(color: Colors.white24, fontSize: 13)),
      ])),

    Expanded(child: Center(child: GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(animation: _ctrl,
        builder: (_, child) => Transform(alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(_ctrl.value * 3.14159),
          child: _ctrl.value < 0.5
              ? _card(_showBack ? _backText : _frontText, false)
              : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateX(3.14159),
                  child: _card(_backText, true)),
        )),
    ))),

    Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withAlpha(6)))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(onTap: _skip, child: Container(width: 64, height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFF8B4242).withAlpha(12), border: Border.all(color: const Color(0xFF8B4242).withAlpha(30))),
          child: const Center(child: Text('✕', style: TextStyle(color: Color(0xFF8B4242), fontSize: 24))))),
        GestureDetector(onTap: _request, child: Container(width: 40, height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(5), border: Border.all(color: Colors.white.withAlpha(10))),
          child: const Center(child: Text('▲', style: TextStyle(color: Colors.white24, fontSize: 16))))),
        GestureDetector(onTap: _flip, child: Container(width: 64, height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFFD4A574).withAlpha(12), border: Border.all(color: const Color(0xFFD4A574).withAlpha(30))),
          child: const Center(child: Text('○', style: TextStyle(color: Color(0xFFD4A574), fontSize: 24))))),
      ])),

    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(height: 32, child: ListView(scrollDirection: Axis.horizontal,
        children: _subjects.map((s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ActionChip(label: Text(s, style: TextStyle(color: _subject == s ? Colors.white : Colors.white38, fontSize: 11)),
            backgroundColor: _subject == s ? const Color(0xFFD4A574).withAlpha(30) : const Color(0xFF141414),
            side: BorderSide(color: Colors.white.withAlpha(_subject == s ? 25 : 8)),
            onPressed: () => _load(s)))).toList())),
    ),
  ])));

  Widget _card(String text, bool isBack) => Container(
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
