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

class _HomeState extends State<Home> {
  final _rng = Random();
  final _cmdCtrl = TextEditingController();

  final List<String> _following = [];
  final List<String> _queue = [];
  int _qIdx = 0;
  String _subject = '영어';
  bool _isBack = false;
  bool _cmdMode = false;  // 학습모드 vs 명령모드
  int _cardNum = 0, _goodCount = 0;
  bool _soundOn = true;

  static const _words = ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다','piano 피아노','queen 여왕','river 강','sun 태양','tree 나무'];
  static const _slang = ['가심비 가격대비심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'];
  static const _math  = ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도'];
  static const _facts = ['한글날 10월9일','광복절 8월15일','개천절 10월3일'];
  static const _subjects = ['영어','신조어','수학','상식','유머','뉴스','팔로우'];
  static const _cardColors = [Color(0xFF2D1B69),Color(0xFF1B3A5C),Color(0xFF3D1A1A),Color(0xFF1A3D2E),Color(0xFF3D2D1A)];
  
  Color get _color => _cardColors[_cardNum % _cardColors.length];

  @override void initState() { super.initState(); _load('영어'); }
  @override void dispose() { _cmdCtrl.dispose(); super.dispose(); }

  void _load(String s) {
    _subject = s; _queue.clear(); _qIdx = 0; _cardNum = 0; _isBack = false; _cmdMode = false;
    if (s == '유머') _queue.addAll(['세상에서가장쉬운AI 이보다더쉬운AI는없다','AI가먼저말걸면 사람은그냥OX','코딩몰라도앱만들기 그게TikiTaka']);
    else if (s == '뉴스') { _queue.add('뉴스 불러오는 중...'); _fetchNews(); }
    else if (s == '팔로우') { if (_following.isEmpty) _queue.add('팔로우없음 ▲손흥민팔로우'); else for(final f in _following) _queue.add('⭐$f $f'); }
    else if (s == '신조어') _queue.addAll(_slang);
    else if (s == '수학') _queue.addAll(_math);
    else if (s == '상식') _queue.addAll(_facts);
    else _queue.addAll(_words);
    _next();
  }

  void _fetchNews() async {
    try {
      final res = await http.get(Uri.parse('https://feeds.bbci.co.uk/news/rss.xml')).timeout(const Duration(seconds: 10));
      final regex = RegExp(r'<item>.*?<title>(.*?)</title>.*?<description>(.*?)</description>',dotAll:true);
      _queue.clear(); _qIdx = 0;
      for(final m in regex.allMatches(res.body).take(10)) {
        final t = m.group(1)?.replaceAll(RegExp(r'<[^>]*>'),'').trim()??'';
        final d = m.group(2)?.replaceAll(RegExp(r'<[^>]*>'),'').replaceAll('&amp;','&').trim()??'';
        _queue.add('$t $d');
      }
    } catch(_) { _queue.clear(); _qIdx=0; _queue.add('연결실패 인터넷을확인해주세요'); }
    if(mounted) setState((){});
  }

  void _next() { if(_queue.isEmpty) _queue.add('...'); _isBack=false; _qIdx=_rng.nextInt(_queue.length); _cardNum++; setState((){}); }

  String get _cur => _queue.isNotEmpty ? _queue[_qIdx%_queue.length] : '';
  String _front() => _cur.contains(' ')?_cur.split(' ').first:_cur;
  String _back() => _cur.contains(' ')?_cur.substring(_cur.indexOf(' ')+1):_cur;

  void _sound() { if(!_soundOn) return; try{ SystemSound.play(SystemSoundType.click); }catch(_){} }

  // ─── Card tap ─────────────────────────────────

  void _tap() {
    if (_cmdMode) return; // command mode: don't flip
    if (_isBack) { _next(); return; }
    _sound(); _isBack = true; _goodCount++; setState((){});
  }

  void _tapX() {
    if (_cmdMode) return;
    if (_isBack) { _next(); return; }
    _sound(); _isBack = true; setState((){});
  }

  // ─── Command mode (▲) ─────────────────────────

  void _toggleCmd() {
    _cmdMode = !_cmdMode;
    if (!_cmdMode) _cmdCtrl.clear();
    setState((){});
  }

  void _submitCmd() {
    final r = _cmdCtrl.text.trim();
    if (r.isEmpty) return;
    _cmdCtrl.clear();
    _sound();

    if (r.contains('뉴스')) _load('뉴스');
    else if (r.contains('팔로우')) { final n = r.replaceAll('팔로우','').trim(); if(n.isNotEmpty) _following.add(n); _load('팔로우'); }
    else if (r.contains('소리 꺼')) { _soundOn = false; _load('영어'); }
    else if (r.contains('소리 켜')) { _soundOn = true; _load('영어'); }
    else if (_subjects.any((s)=>r.contains(s))) _load(_subjects.firstWhere((s)=>r.contains(s)));
    else _load(_subject);

    _cmdMode = false; _isBack = false; _next();
    setState((){});
  }

  // ─── UI ───────────────────────────────────────

  @override Widget build(_) => Scaffold(body: SafeArea(child: Column(children: [
    Container(padding: const EdgeInsets.fromLTRB(20,12,20,8),
      child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        Text(_cmdMode?'⌨️ 명령모드':'🃏 TikiTaka',style:TextStyle(color:Color(0xFFD4A574),fontSize:16,fontWeight:FontWeight.w700)),
        Text('$_goodCount장',style:TextStyle(color:Colors.white24,fontSize:13)),
      ])),

    Expanded(child: Center(child: AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (w,a) => SlideTransition(position:Tween(begin:Offset(1,0),end:Offset.zero).animate(a),child:FadeTransition(opacity:a,child:w)),
      child: GestureDetector(onTap:_tap,
        child: _cmdMode ? _cmdCard() : _card(_isBack ? _back() : _front(), _isBack)),
    ))),

    // Bottom bar
    Container(decoration:BoxDecoration(border:Border(top:BorderSide(color:Colors.white.withAlpha(6)))),
      padding:EdgeInsets.symmetric(horizontal:24,vertical:14),
      child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        GestureDetector(onTap:_tapX,child:Container(width:64,height:48,
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),color:Color(0xFF8B4242).withAlpha(12),border:Border.all(color:Color(0xFF8B4242).withAlpha(30))),
          child:Center(child:Text('✕',style:TextStyle(color:Color(0xFF8B4242),fontSize:24))))),
        GestureDetector(onTap:_toggleCmd,child:Container(width:40,height:40,
          decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white.withAlpha(_cmdMode?15:5),border:Border.all(color:_cmdMode?Color(0xFFD4A574).withAlpha(40):Colors.white.withAlpha(10))),
          child:Center(child:Text('▲',style:TextStyle(color:_cmdMode?Color(0xFFD4A574):Colors.white24,fontSize:16))))),
        GestureDetector(onTap:_tap,child:Container(width:64,height:48,
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),color:Color(0xFFD4A574).withAlpha(12),border:Border.all(color:Color(0xFFD4A574).withAlpha(30))),
          child:Center(child:Text('○',style:TextStyle(color:Color(0xFFD4A574),fontSize:24))))),
      ])),

    Padding(padding:EdgeInsets.fromLTRB(12,0,12,12),
      child:SizedBox(height:32,child:ListView(scrollDirection:Axis.horizontal,
        children:_subjects.map((s)=>Padding(padding:EdgeInsets.symmetric(horizontal:3),
          child:ActionChip(label:Text(s,style:TextStyle(color:_subject==s?Colors.white:Colors.white38,fontSize:11)),
            backgroundColor:_subject==s?Color(0xFFD4A574).withAlpha(30):Color(0xFF141414),
            side:BorderSide(color:Colors.white.withAlpha(_subject==s?25:8)),
            onPressed:()=>_load(s)))).toList())),
    ),
  ])));

  Widget _cmdCard() => Container(
    margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(28),
    decoration:BoxDecoration(
      gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF1A1A1A),Color(0xFF111111),Color(0xFF0A0A0A)]),
      borderRadius:BorderRadius.circular(24),
      border:Border.all(color:Color(0xFFD4A574).withAlpha(50)),
      boxShadow:[BoxShadow(color:Color(0xFFD4A574).withAlpha(30),blurRadius:30,offset:Offset(0,12))]),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Text('무엇을 도와드릴까요?',style:TextStyle(color:Color(0xFFD4A574),fontSize:18,fontWeight:FontWeight.w600)),
      SizedBox(height:16),
      TextField(controller:_cmdCtrl,autofocus:true,style:TextStyle(color:Colors.white),
        decoration:InputDecoration(hintText:'"뉴스" "영어" "소리 꺼줘"',hintStyle:TextStyle(color:Colors.white24),
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide(color:Colors.white.withAlpha(20))),
          focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide(color:Color(0xFFD4A574))))),
      SizedBox(height:12),
      Row(mainAxisAlignment:MainAxisAlignment.end,children:[
        GestureDetector(onTap:_submitCmd,child:Container(padding:EdgeInsets.symmetric(horizontal:24,vertical:12),
          decoration:BoxDecoration(color:Color(0xFFD4A574),borderRadius:BorderRadius.circular(12)),
          child:Text('전송',style:TextStyle(color:Color(0xFF0A0A0A),fontWeight:FontWeight.w600)))),
      ]),
    ]));

  Widget _card(String text, bool isBack) => Container(
    margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(28),
    decoration:BoxDecoration(
      gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[Color.lerp(_color,Colors.white,0.1)!,_color,Color.lerp(_color,Colors.black,0.3)!]),
      borderRadius:BorderRadius.circular(24),
      border:Border.all(color:isBack?Colors.white.withAlpha(15):_color.withAlpha(100),width:1.5),
      boxShadow:[BoxShadow(color:_color.withAlpha(80),blurRadius:30,offset:Offset(0,12))]),
    child:Center(child:Text(text,textAlign:TextAlign.center,
      style:TextStyle(color:isBack?Colors.white70:Colors.white,fontSize:isBack?20:28,fontWeight:isBack?FontWeight.w400:FontWeight.w600,height:1.5))));
}
