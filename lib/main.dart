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
  final _rng = Random(), _cmdCtrl = TextEditingController();
  late FlutterTts _tts;
  final List<String> _following = [], _queue = [];
  int _qIdx = 0;
  String _subject = '영어';
  bool _isBack = false, _cmdMode = false, _soundOn = true, _ttsReady = false;
  int _cardNum = 0, _goodCount = 0;
  String _cmdPending = '';

  // Independent button positions
  double _xX = 20, _yX = 0;   // ✕ button
  double _xTri = 120, _yTri = 0; // ▲ button  
  double _xO = 220, _yO = 0;  // ○ button

  static const _words = ['apple 사과','book 책','cat 고양이','dog 개','elephant 코끼리','flower 꽃','garden 정원','house 집','ice 얼음','jungle 정글','king 왕','lion 사자','moon 달','night 밤','ocean 바다','piano 피아노','queen 여왕','river 강','sun 태양','tree 나무'];
  static const _slang = ['가심비 가격대비심리적만족도','스불재 스스로불러온재앙','중꺾마 중요한건꺾이지않는마음','킹받다 열받다','억텐 억지텐션','점메추 점심메뉴추천','소확행 소소하지만확실한행복'];
  static const _math  = ['E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 힘=질량×가속도'];
  static const _facts = ['한글날 10월9일','광복절 8월15일','개천절 10월3일'];
  static const _subjects = ['영어','영어듣기','신조어','수학','상식','유머','뉴스','팔로우'];
  static const _colors = [Color(0xFF2D1B69),Color(0xFF1B3A5C),Color(0xFF3D1A1A),Color(0xFF1A3D2E),Color(0xFF3D2D1A)];
  
  // 🔊 Listening content
  static const _listening = [
    'The weather is beautiful today.',
    'Could you help me please?',
    'I would like a cup of coffee.',
    'Where is the nearest station?',
    'What time does it start?',
    'How much does this cost?',
    'Nice to meet you.',
    'See you tomorrow.',
    'Would you like to join us?',
    'I have been waiting for an hour.',
  ];

  Color get _color => _colors[_cardNum % _colors.length];

  @override void initState() { super.initState(); _initTts(); _load('영어'); }
  @override void dispose() { _cmdCtrl.dispose(); _tts.stop(); super.dispose(); }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
        await _tts.setVoice({'name': 'ko-kr-x-kod-local'}); // female
        _ttsReady = true;
  }

  void _load(String s) {
    _subject = s; _queue.clear(); _qIdx = 0; _cardNum = 0; _isBack = false;
    switch (s) {
      case '영어듣기':
        _queue.addAll(_listening);
        break;
      case '유머':
        _queue.addAll(['세상에서가장쉬운AI 이보다더쉬운AI는없다','AI먼저말걸면 사람은그냥OX','코딩1도모르고만든앱 그게TikiTaka']);
        break;
      case '뉴스':
        _queue.add('로딩...'); _fetchNews(); break;
      case '팔로우':
        if(_following.isEmpty)_queue.add('팔로우없음 ▲명령'); else for(final f in _following)_queue.add('⭐$f $f님의소식');
        break;
      case '신조어': _queue.addAll(_slang); break;
      case '수학': _queue.addAll(_math); break;
      case '상식': _queue.addAll(_facts); break;
      default: _queue.addAll(_words);
    }
    _next();
  }

  void _fetchNews() async {
    try {
      final res = await http.get(Uri.parse('https://feeds.bbci.co.uk/news/rss.xml')).timeout(Duration(seconds: 10));
      final re = RegExp(r'<item>.*?<title>(.*?)</title>.*?<description>(.*?)</description>',dotAll:true);
      _queue.clear(); _qIdx=0;
      for(final m in re.allMatches(res.body).take(10)) {
        final t=m.group(1)?.replaceAll(RegExp(r'<[^>]*>'),'').trim()??'';
        final d=m.group(2)?.replaceAll(RegExp(r'<[^>]*>'),'').replaceAll('&amp;','&').trim()??'';
        _queue.add('$t $d');
      }
    } catch(_) { _queue.clear();_qIdx=0;_queue.add('연결실패 인터넷확인'); }
    if(mounted) setState((){});
  }

  void _next() { if(_queue.isEmpty)_queue.add('...'); _isBack=false; _qIdx=_rng.nextInt(_queue.length); _cardNum++; _speakF(); setState((){}); }
  String get _cur => _queue.isNotEmpty?_queue[_qIdx%_queue.length]:'';
  String _front() {
    if(_subject=='영어듣기') return '절대로 의미를 생각하지 마시고\n소리에만 집중하세요!';
    return _cur.contains(' ')?_cur.split(' ').first:_cur;
  }
  String _back() {
    if(_subject=='영어듣기') return _cur; // English text only, no Korean
    return _cur.contains(' ')?_cur.substring(_cur.indexOf(' ')+1):_cur;
  }

  bool _maleVoice = false; // false=female (default)

  // ─── 🏓 LOUD ping-pong ────────────────────────

  void _pong() {
    if (!_soundOn) return;
    // Heavy haptic + rapid double-click for audible ping-pong
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      SystemSound.play(SystemSoundType.click);
    });
  }

  Future<void> _speakF() async {
    if(!_soundOn||!_ttsReady||_cmdMode)return;
    await _tts.stop();
    if(_subject=='영어'||_subject=='영어듣기') await _tts.setLanguage('en-US');
    else await _tts.setLanguage('ko-KR');
    // 영어듣기: speak the English sentence (front is hidden)
    if(_subject=='영어듣기') await _tts.speak(_cur);
    else await _tts.speak(_front());
  }
  Future<void> _speakB() async {
    if(!_soundOn||!_ttsReady||_cmdMode)return;
    await _tts.stop();
    if(_subject=='영어'||_subject=='영어듣기') await _tts.setLanguage('en-US');
    else await _tts.setLanguage('ko-KR');
    // 영어듣기 back: speak English sentence again
    if(_subject=='영어듣기') await _tts.speak(_cur);
    else await _tts.speak(_back());
  }

  void _onO() {
    if(_cmdMode) {
      if(!_isBack){_isBack=true;_pong();setState((){});return;}
      _pong();_tts.stop();if(_cmdPending.isNotEmpty)_load(_cmdPending);else _load(_subject);
      _cmdMode=false;_cmdPending='';_cmdCtrl.clear();setState((){});return;
    }
    if(_isBack){_pong();_next();return;}
    _pong();_isBack=true;_goodCount++;_speakB();setState((){});
  }
  void _onX() {
    if(_cmdMode){_isBack=false;_cmdPending='';_cmdMode=false;_cmdCtrl.clear();_pong();setState((){});return;}
    if(_isBack){_pong();_next();return;}
    _pong();_isBack=true;_speakB();setState((){});
  }
  void _toggleCmd(){_cmdMode=!_cmdMode;_isBack=false;_cmdPending='';_cmdCtrl.clear();_tts.stop();setState((){});}
  void _selectSubject(String s){_cmdPending=s;_isBack=true;_pong();setState((){});}
  void _submitText(){
    final r=_cmdCtrl.text.trim();if(r.isEmpty)return;_cmdCtrl.clear();
    if(r.contains('팔로우')){final n=r.replaceAll('팔로우','').trim();if(n.isNotEmpty)_following.add(n);_cmdPending='팔로우';}
    else if(r.contains('소리 꺼')){_soundOn=false;_tts.stop();_cmdPending='영어';}
    else if(r.contains('여자 목소리')||r.contains('여성')){_maleVoice=false;_tts.setVoice({'name':'ko-kr-x-kod-local'});_cmdPending='영어';}
    else if(r.contains('남자 목소리')||r.contains('남성')){_maleVoice=true;_tts.setVoice({'name':'ko-kr-x-kom-local'});_cmdPending='영어';}
    else if(r.contains('소리 켜')){_soundOn=true;_cmdPending='영어';}
    else if(_subjects.any((s)=>r.contains(s)))_cmdPending=_subjects.firstWhere((s)=>r.contains(s));
    else _cmdPending=r;
    _isBack=true;_pong();setState((){});
  }

  @override Widget build(_) => Scaffold(body: SafeArea(child: Stack(children: [
    Column(children: [
      Container(padding:EdgeInsets.fromLTRB(20,12,20,8),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text(_cmdMode?'▲ 명령':'🃏 TikiTaka',style:TextStyle(color:Color(0xFFD4A574),fontSize:16,fontWeight:FontWeight.w700)),
          Text('$_goodCount장',style:TextStyle(color:Colors.white24,fontSize:13)),
        ])),
      Expanded(child:Center(child:AnimatedSwitcher(
        duration:Duration(milliseconds:300),switchInCurve:Curves.easeOutBack,
        transitionBuilder:(w,a)=>SlideTransition(position:Tween(begin:Offset(1,0),end:Offset.zero).animate(a),child:FadeTransition(opacity:a,child:w)),
        child:_cmdMode&&_isBack?_card('"$_cmdPending"을(를)\n시작합니다.',true):_cmdMode?_cmdCard():_card(_isBack?_back():_front(),_isBack),
      ))),
    ]),

    // ✕ button — draggable independently
    Positioned(left:_xX,bottom:100+_yX,child:GestureDetector(onPanUpdate:(d)=>setState((){_xX+=d.delta.dx;_yX-=d.delta.dy;}),child:_btnBig('✕',Color(0xFF8B4242),_onX))),
    // ▲ button — draggable independently
    Positioned(left:_xTri,bottom:100+_yTri,child:GestureDetector(onPanUpdate:(d)=>setState((){_xTri+=d.delta.dx;_yTri-=d.delta.dy;}),child:_btnTri(_toggleCmd))),
    // ○ button — draggable independently
    Positioned(left:_xO,bottom:100+_yO,child:GestureDetector(onPanUpdate:(d)=>setState((){_xO+=d.delta.dx;_yO-=d.delta.dy;}),child:_btnBig('○',Color(0xFFD4A574),_onO))),
  ])));

  Widget _btnBig(String s,Color c,VoidCallback fn)=>GestureDetector(onTap:fn,child:Container(width:72,height:72,
      decoration:BoxDecoration(shape:BoxShape.circle,color:c.withAlpha(25),border:Border.all(color:c.withAlpha(60),width:2.5)),
      child:Center(child:Text(s,style:TextStyle(color:c,fontSize:36,fontWeight:FontWeight.w200)))));

  Widget _btnTri(VoidCallback fn)=>GestureDetector(onTap:fn,child:Container(width:56,height:56,
      decoration:BoxDecoration(shape:BoxShape.circle,color:_cmdMode?Color(0xFFD4A574).withAlpha(25):Colors.white.withAlpha(8),border:Border.all(color:_cmdMode?Color(0xFFD4A574).withAlpha(50):Colors.white.withAlpha(15))),
      child:Center(child:Text('▲',style:TextStyle(color:_cmdMode?Color(0xFFD4A574):Colors.white30,fontSize:28)))));

  Widget _cmdCard()=>Container(margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(24),
    decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF1A1A1A),Color(0xFF111111),Color(0xFF0A0A0A)]),
      borderRadius:BorderRadius.circular(24),border:Border.all(color:Color(0xFFD4A574).withAlpha(50)),
      boxShadow:[BoxShadow(color:Color(0xFFD4A574).withAlpha(20),blurRadius:30,offset:Offset(0,12))]),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Text('무엇을 도와드릴까요?',style:TextStyle(color:Color(0xFFD4A574),fontSize:18,fontWeight:FontWeight.w600)),
      SizedBox(height:16),
      Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,
        children:_subjects.map((s)=>ActionChip(label:Text(s,style:TextStyle(color:Colors.white70,fontSize:12)),backgroundColor:Color(0xFF1A1A1A),side:BorderSide(color:Colors.white.withAlpha(15)),onPressed:()=>_selectSubject(s))).toList()),
      SizedBox(height:16),
      Row(children:[
        Expanded(child:TextField(controller:_cmdCtrl,style:TextStyle(color:Colors.white,fontSize:14),
          decoration:InputDecoration(hintText:'직접 입력...',hintStyle:TextStyle(color:Colors.white24,fontSize:13),contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:10),
            border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.white.withAlpha(20)))))),
        SizedBox(width:8),
        GestureDetector(onTap:_submitText,child:Container(padding:EdgeInsets.all(10),decoration:BoxDecoration(color:Color(0xFFD4A574),borderRadius:BorderRadius.circular(10)),child:Icon(Icons.send,color:Color(0xFF0A0A0A),size:20))),
      ]),
    ]));

  Widget _card(String text,bool isBack)=>Container(margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(28),
    decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color.lerp(_color,Colors.white,0.1)!,_color,Color.lerp(_color,Colors.black,0.3)!]),
      borderRadius:BorderRadius.circular(24),border:Border.all(color:isBack?Colors.white.withAlpha(15):_color.withAlpha(100),width:1.5),
      boxShadow:[BoxShadow(color:_color.withAlpha(80),blurRadius:30,offset:Offset(0,12))]),
    child:Center(child:Text(text,textAlign:TextAlign.center,
      style:TextStyle(color:isBack?Colors.white70:Colors.white,fontSize:isBack?20:28,fontWeight:isBack?FontWeight.w400:FontWeight.w600,height:1.5))));
}
