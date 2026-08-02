import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final FlutterTts _tts = FlutterTts();
  final List<String> _following = [];
  final List<String> _queue = [];
  int _qIdx = 0;
  String _subject = '영어';
  bool _isBack = false, _cmdMode = false, _soundOn = true;
  int _cardNum = 0, _goodCount = 0;

  // Floating button position
  double _barX = 0, _barY = 0;

  static const _words = ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다'];
  static const _slang = ['가심비 가격대비심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'];
  static const _math  = ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도'];
  static const _facts = ['한글날 10월9일','광복절 8월15일','개천절 10월3일'];
  static const _subjects = ['영어','신조어','수학','상식','유머','뉴스','팔로우'];
  static const _colors = [Color(0xFF2D1B69),Color(0xFF1B3A5C),Color(0xFF3D1A1A),Color(0xFF1A3D2E),Color(0xFF3D2D1A)];
  Color get _color => _colors[_cardNum % _colors.length];

  // Command mode state
  String _cmdPending = ''; // what subject was selected

  @override void initState() {
    super.initState();
    _tts.setLanguage('ko-KR');
    _tts.setSpeechRate(0.5); // 1.25x faster (0.5 = fast in flutter_tts)
    _tts.setPitch(1.0);
    _load('영어');
  }
  @override void dispose() { _cmdCtrl.dispose(); super.dispose(); }

  void _load(String s) {
    _subject = s; _queue.clear(); _qIdx = 0; _cardNum = 0; _isBack = false;
    if (s == '유머') _queue.addAll(['세상에서가장쉬운AI 이보다더쉬운AI없다','AI가먼저말걸면 사람은그냥OX','코딩몰라도만드는앱 그게TikiTaka']);
    else if (s == '뉴스') { _queue.add('로딩중...'); _fetchNews(); }
    else if (s == '팔로우') { if(_following.isEmpty)_queue.add('팔로우없음 ▲손흥민팔로우'); else for(final f in _following)_queue.add('⭐$f $f'); }
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
      _queue.clear(); _qIdx=0;
      for(final m in regex.allMatches(res.body).take(10)) {
        final t=m.group(1)?.replaceAll(RegExp(r'<[^>]*>'),'').trim()??'';
        final d=m.group(2)?.replaceAll(RegExp(r'<[^>]*>'),'').replaceAll('&amp;','&').trim()??'';
        _queue.add('$t $d');
      }
    } catch(_) { _queue.clear();_qIdx=0;_queue.add('연결실패 인터넷확인'); }
    if(mounted) setState((){});
  }

  void _next() { if(_queue.isEmpty)_queue.add('...'); _isBack=false; _qIdx=_rng.nextInt(_queue.length); _cardNum++; _speak(_front()); setState((){}); }
  String get _cur => _queue.isNotEmpty?_queue[_qIdx%_queue.length]:'';
  String _front() => _cur.contains(' ')?_cur.split(' ').first:_cur;
  String _back() => _cur.contains(' ')?_cur.substring(_cur.indexOf(' ')+1):_cur;
  void _sound() { if(!_soundOn)return; try{SystemSound.play(SystemSoundType.click);}catch(_){} }
  void _speak(String text) async {
    if (!_soundOn) return;
    try { await _tts.stop(); await _tts.speak(text); } catch (_) {}
  }

  void _onO() {
    if (_cmdMode) {
      if (!_isBack) { _isBack = true; _sound(); setState((){}); return; }
      _sound();
      if (_cmdPending.isNotEmpty) { _load(_cmdPending); } else { _load(_subject); }
      _cmdMode = false; _cmdPending = ''; _cmdCtrl.clear();
      setState((){}); return;
    }
    if (_isBack) { _next(); return; }
    _sound(); _isBack = true; _goodCount++; _speak(_back()); setState((){});
  }

  void _onX() {
    if (_cmdMode) {
      _isBack = false; _cmdPending = ''; _cmdMode = false; _cmdCtrl.clear();
      setState((){}); return;
    }
    if (_isBack) { _next(); return; }
    _sound(); _isBack = true; _speak(_back()); setState((){});
  }

  void _toggleCmd() {
    _cmdMode = !_cmdMode; _isBack = false; _cmdPending = ''; _cmdCtrl.clear();
    setState((){});
  }

  void _selectSubject(String s) {
    _cmdPending = s; _isBack = true; _sound(); setState((){});
  }

  void _submitText() {
    final r = _cmdCtrl.text.trim();
    if (r.isEmpty) return;
    if (r.contains('팔로우')) { final n=r.replaceAll('팔로우','').trim(); if(n.isNotEmpty)_following.add(n); _cmdPending='팔로우'; }
    else if (r.contains('소리 꺼')) { _soundOn=false; _cmdPending='유머'; }
    else if (r.contains('소리 켜')) { _soundOn=true; _cmdPending='유머'; }
    else if (_subjects.any((s)=>r.contains(s))) _cmdPending=_subjects.firstWhere((s)=>r.contains(s));
    else _cmdPending = r;
    _isBack = true; _sound(); _cmdCtrl.clear();
    setState((){});
  }

  @override Widget build(_) => Scaffold(body: SafeArea(child: Stack(children: [
    Column(children: [
      Container(padding: const EdgeInsets.fromLTRB(20,12,20,8),
        child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text(_cmdMode?'▲ 명령':'🃏 TikiTaka',style:TextStyle(color:Color(0xFFD4A574),fontSize:16,fontWeight:FontWeight.w700)),
          Text('$_goodCount장',style:TextStyle(color:Colors.white24,fontSize:13)),
        ])),

      Expanded(child: Center(child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300), switchInCurve: Curves.easeOutBack,
        transitionBuilder: (w,a) => SlideTransition(position:Tween(begin:Offset(1,0),end:Offset.zero).animate(a),
          child:FadeTransition(opacity:a,child:w)),
        child: _cmdMode ? _cmdCard() : _card(_isBack?_back():_front(), _isBack),
      ))),
    ]),

    // Draggable button bar
    Positioned(left:_barX+20, bottom:80+_barY, child:GestureDetector(
      onPanUpdate:(d)=>setState((){_barX+=d.delta.dx;_barY-=d.delta.dy;}),
      child:Container(
        decoration:BoxDecoration(color:Color(0xFF1A1A1A).withAlpha(230),borderRadius:BorderRadius.circular(16),
          border:Border.all(color:Colors.white.withAlpha(15)),boxShadow:[BoxShadow(color:Colors.black54,blurRadius:16)]),
        padding:EdgeInsets.symmetric(horizontal:16,vertical:10),
        child:Row(mainAxisSize:MainAxisSize.min,children:[
          GestureDetector(onTap:_onX,child:_btnInner('✕',Color(0xFF8B4242))),SizedBox(width:12),
          GestureDetector(onTap:_toggleCmd,child:Container(width:32,height:32,
            decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white.withAlpha(_cmdMode?15:5)),
            child:Center(child:Text('▲',style:TextStyle(color:_cmdMode?Color(0xFFD4A574):Colors.white24,fontSize:14))))),SizedBox(width:12),
          GestureDetector(onTap:_onO,child:_btnInner('○',Color(0xFFD4A574))),
        ])))),
  ])));

  Widget _btnInner(String s, Color c) => Container(width:40,height:40,
    decoration:BoxDecoration(borderRadius:BorderRadius.circular(10),color:c.withAlpha(20),border:Border.all(color:c.withAlpha(40))),
    child:Center(child:Text(s,style:TextStyle(color:c,fontSize:20))));

  Widget _cmdCard() {
    if (_isBack) {
      // Back: confirmation
      return _card('"$_cmdPending"을(를)\n시작합니다.', true);
    }
    // Front: subject list + text input
    return Container(
      margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(24),
      decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[Color(0xFF1A1A1A),Color(0xFF111111),Color(0xFF0A0A0A)]),
        borderRadius:BorderRadius.circular(24),border:Border.all(color:Color(0xFFD4A574).withAlpha(50)),
        boxShadow:[BoxShadow(color:Color(0xFFD4A574).withAlpha(20),blurRadius:30,offset:Offset(0,12))]),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text('무엇을 도와드릴까요?',style:TextStyle(color:Color(0xFFD4A574),fontSize:18,fontWeight:FontWeight.w600)),
        SizedBox(height:16),
        Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,
          children:_subjects.map((s)=>ActionChip(
            label:Text(s,style:TextStyle(color:Colors.white70,fontSize:12)),
            backgroundColor:Color(0xFF1A1A1A),
            side:BorderSide(color:Colors.white.withAlpha(15)),
            onPressed:()=>_selectSubject(s))).toList()),
        SizedBox(height:16),
        Row(children:[
          Expanded(child:TextField(controller:_cmdCtrl,style:TextStyle(color:Colors.white,fontSize:14),
            decoration:InputDecoration(hintText:'직접 입력...',hintStyle:TextStyle(color:Colors.white24,fontSize:13),
              contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:10),
              border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.white.withAlpha(20)))))),
          SizedBox(width:8),
          GestureDetector(onTap:_submitText,child:Container(padding:EdgeInsets.all(10),
            decoration:BoxDecoration(color:Color(0xFFD4A574),borderRadius:BorderRadius.circular(10)),
            child:Icon(Icons.send,color:Color(0xFF0A0A0A),size:20))),
        ]),
      ]));
  }

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
