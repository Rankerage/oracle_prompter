import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'services/adaptive_fsrs.dart';
import 'services/content_fsrs.dart';
import 'services/card_factory.dart';
import 'services/tikitaka_brain.dart';
import 'services/card_pool.dart';
import 'services/volume_ox.dart';
import 'services/hermes_bridge.dart';
import 'services/mneme.dart';
import 'services/mystic_deck.dart';
import 'services/oracle.dart';

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
  final _brain = TikiTakaBrain();
  final _hermes = HermesBridge();
  final _mneme = Mneme();
  final _oracle = Oracle();
  final List<String> _queue = [];
  int _qIdx = 0;
  String _subject = '영어', _mode = 'learn'; // learn | cmd
  bool _isBack = false, _soundOn = true, _ttsReady = false;
  int _cardNum = 0, _goodCount = 0;

  // Command card state — 질문 계층: binary > multi-chip > text
  String _cmdStep = ''; // 'menu' | 'engine' | 'confirm' | 'text'
  String _cmdEngine = ''; 

  // Buttons
  double _xX = 20, _yX = 0, _xTri = 110, _yTri = 0, _xO = 200, _yO = 0;

  static const _subjects = ['영어','영어듣기','신조어','수학','상식','유머','뉴스','AI상식','건강','사주','별자리','질문'];
  static const _colors = [Color(0xFF2D1B69),Color(0xFF1B3A5C),Color(0xFF3D1A1A),Color(0xFF1A3D2E),Color(0xFF3D2D1A)];
  Color get _color => _colors[_cardNum % _colors.length];

  @override void initState() {
    super.initState();
    _initTts();
    _load('영어');
    VolumeOX().enable(onO: _onO, onX: _onX);
  }
  @override void dispose() { _cmdCtrl.dispose(); _tts.stop(); super.dispose(); }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _ttsReady = true;
  }

  // ─── Deck ──────────────────────────────────────

  void _load(String s) {
    _subject = s; _queue.clear(); _qIdx = 0; _cardNum = 0; _isBack = false; _mode = 'learn';
    if (s == '뉴스') { _queue.add('로딩...'); _fetchNews(); }
    else { _queue.addAll(CardFactory.deckFor(s)); }
    _next();
  }

  void _fetchNews() async {
    try {
      final res = await http.get(Uri.parse('https://feeds.bbci.co.uk/news/rss.xml')).timeout(Duration(seconds:10));
      final re = RegExp(r'<item>.*?<title>(.*?)</title>.*?<description>(.*?)</description>',dotAll:true);
      _queue.clear(); _qIdx=0;
      for(final m in re.allMatches(res.body).take(10)) {
        final t=m.group(1)?.replaceAll(RegExp(r'<[^>]*>'),'').trim()??'';
        final d=m.group(2)?.replaceAll(RegExp(r'<[^>]*>'),'').replaceAll('&amp;','&').trim()??'';
        _queue.add('$t $d');
      }
    } catch(_) { _queue.clear(); _qIdx=0; _queue.add('연결실패 인터넷확인'); }
    if(mounted) setState((){});
  }

  void _next() { if(_queue.isEmpty)_queue.add('...'); _isBack=false; _qIdx=_rng.nextInt(_queue.length); _cardNum++; _speakF(); setState((){}); }
  String get _cur => _queue.isNotEmpty?_queue[_qIdx%_queue.length]:'';
  String _front() {
    if(_subject=='영어듣기') return '소리에만 집중하세요\n의미는 생각하지 마시고';
    return _cur.contains(' ')?_cur.split(' ').first:_cur;
  }
  String _back() {
    if(_subject=='영어듣기') return _cur;
    return _cur.contains(' ')?_cur.substring(_cur.indexOf(' ')+1):_cur;
  }

  void _pong() { if(!_soundOn)return;
    HapticFeedback.heavyImpact();SystemSound.play(SystemSoundType.click);
    Future.delayed(Duration(milliseconds:80),(){HapticFeedback.mediumImpact();SystemSound.play(SystemSoundType.alert);});
    Future.delayed(Duration(milliseconds:160),(){SystemSound.play(SystemSoundType.click);});}

  Future<void> _speakF() async {
    if(!_soundOn||!_ttsReady)return;
    await _tts.stop();
    if(_subject=='영어'||_subject=='영어듣기') await _tts.setLanguage('en-US'); else await _tts.setLanguage('ko-KR');
    if(_subject=='영어듣기') await _tts.speak(_cur); else await _tts.speak(_front());
  }
  Future<void> _speakB() async {
    if(!_soundOn||!_ttsReady)return;
    await _tts.stop();
    if(_subject=='영어'||_subject=='영어듣기') await _tts.setLanguage('en-US'); else await _tts.setLanguage('ko-KR');
    if(_subject=='영어듣기') await _tts.speak(_cur); else await _tts.speak(_back());
  }

  // ─── Actions ──────────────────────────────────

  void _onO() {
    if (_mode=='cmd') { _cmdO(); return; }
    if (_isBack) { _pong(); _brain.recordCard(subject:_subject,known:true); _next(); return; }
    _pong(); _isBack=true; _goodCount++; _speakB(); setState((){});
  }

  void _onX() {
    if (_mode=='cmd') { _mode='learn'; _cmdStep=''; _cmdEngine=''; _cmdCtrl.clear(); _pong(); setState((){}); return; }
    if (_isBack) { _pong(); _brain.recordCard(subject:_subject,known:false); _next(); return; }
    _pong(); _isBack=true; _speakB(); setState((){});
  }

  void _cmdO() {
    // Binary step: menu → engine list
    if (_cmdStep == '') {
      _cmdStep = 'engine'; setState((){}); return;
    }
    // Engine selected: show options
    if (_cmdStep == 'engine' && _cmdEngine.isNotEmpty) {
      _cmdStep = 'confirm'; _pong(); setState((){}); return;
    }
    // Confirmed: execute
    if (_cmdStep == 'confirm') {
      _execute(); return;
    }
  }

  void _modeSwitch() {
    if (_mode == 'learn') {
      _mode = 'cmd'; _cmdStep = ''; _cmdEngine = ''; _cmdCtrl.clear(); _isBack = false;
    } else {
      _mode = 'learn'; _cmdStep = ''; _cmdEngine = ''; _cmdCtrl.clear();
    }
    _pong(); _tts.stop(); setState((){});
  }

  void _selectEngine(String e) { _cmdEngine = e; _cmdStep = 'engine'; _pong(); setState((){}); }

  void _execute() {
    _pong(); _tts.stop();
    _mode = 'learn';

    switch (_cmdEngine) {
      case '영어': case '영어듣기': case '신조어': case '수학': case '상식': case '유머': case '뉴스':
      case 'AI상식': case '건강': case '사주': case '별자리':
        _load(_cmdEngine); break;
      case '메모':
        _mneme.remember(_cmdCtrl.text.isNotEmpty?_cmdCtrl.text:'새 메모');
        _queue.clear(); _qIdx = 0;
        _queue.addAll(_mneme.noteCards.map((c)=>'${c['front']} ${c['back']}'));
        _next();
        break;
      case '건강문진':
        _queue.clear(); _qIdx = 0;
        final q = _hermes.hygieia.nextQuestion() ?? '건강 상담이 완료되었습니다.';
        _queue.add('건강문진 $q');
        _next();
        break;
      case '운세':
        final today = MysticDeck().dailyFortune();
        _queue.clear(); _qIdx = 0;
        _queue.add('오늘의 운세 $today');
        _next();
        break;
      case '질문':
        if (_cmdCtrl.text.isNotEmpty) {
          _queue.clear(); _qIdx = 0;
          _queue.add('${_cmdCtrl.text} 잠시만 기다려주세요...');
          _next();
          _oracle.ask(_cmdCtrl.text).then((card) {
            _queue.clear(); _qIdx = 0;
            _queue.add('${card['front']} ${card['back']}');
            _next();
            if (mounted) setState((){});
          });
        }
        break;
      default:
        _load('영어');
    }
    _cmdCtrl.clear();
    setState((){});
  }

  // ─── UI ───────────────────────────────────────

  @override Widget build(_) => Scaffold(body: SafeArea(child: Stack(children: [
    Column(children: [
      Container(padding:EdgeInsets.fromLTRB(20,12,20,8),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text(_mode=='cmd'?'▲ 요청':'🃏 TikiTaka',style:TextStyle(color:Color(0xFFD4A574),fontSize:16,fontWeight:FontWeight.w700)),
          Text('$_goodCount장',style:TextStyle(color:Colors.white24,fontSize:13)),
        ])),
      Expanded(child:Center(child:AnimatedSwitcher(
        duration:Duration(milliseconds:300),switchInCurve:Curves.easeOutBack,
        transitionBuilder:(w,a)=>SlideTransition(position:Tween(begin:Offset(1,0),end:Offset.zero).animate(a),child:FadeTransition(opacity:a,child:w)),
        child:_mode=='cmd'?_cmdCard():_card(_isBack?_back():_front(),_isBack),
      ))),
    ]),
    // Buttons
    Positioned(left:_xX,bottom:100+_yX,child:GestureDetector(onPanUpdate:(d)=>setState((){_xX+=d.delta.dx;_yX-=d.delta.dy;}),child:_btn('✕',Color(0xFF8B4242),_onX))),
    Positioned(left:_xTri,bottom:100+_yTri,child:GestureDetector(onPanUpdate:(d)=>setState((){_xTri+=d.delta.dx;_yTri-=d.delta.dy;}),child:_btn('▲',_mode=='cmd'?Color(0xFFD4A574):Colors.white24,_modeSwitch))),
    Positioned(left:_xO,bottom:100+_yO,child:GestureDetector(onPanUpdate:(d)=>setState((){_xO+=d.delta.dx;_yO-=d.delta.dy;}),child:_btn('○',Color(0xFFD4A574),_onO))),
  ])));

  Widget _btn(String s,Color c,VoidCallback fn)=>GestureDetector(onTap:fn,
    child:Container(width:72,height:72,decoration:BoxDecoration(shape:BoxShape.circle,color:c.withAlpha(25),border:Border.all(color:c.withAlpha(60),width:2.5)),
      child:Center(child:Text(s,style:TextStyle(color:c,fontSize:36,fontWeight:FontWeight.w200)))));

  // ─── Command card (질문 계층 엄수) ─────────────

  Widget _cmdCard() {
    // Step 0: Main menu — binary (배우기 / 분석받기)
    if (_cmdStep == '') {
      return _cardFull('TikiTaka 요청', '',
        chips: ['📚 배우기', '🔍 분석받기'],
        onSelect: (c) {
          if (c.contains('배우기')) _cmdStep = 'engine'; else _cmdStep = 'engine';
          setState((){});
        });
    }

    // Step 1: Engine selection — multi-choice
    if (_cmdStep == 'engine' && _cmdEngine.isEmpty) {
      return _cardFull('원하는 서비스', '',
        chips: _subjects.sublist(0,8) + ['건강문진', '운세', '메모', '질문'],
        onSelect: _selectEngine);
    }

    // Step 2: Confirmation — binary
    if (_cmdStep == 'engine' && _cmdEngine.isNotEmpty) {
      return _cardFull(_cmdEngine, '이 서비스를 시작할까요',
        chips: ['○ 시작', '✕ 취소'],
        onSelect: (c) {
          if (c.contains('시작')) _cmdStep = 'confirm'; else _modeSwitch();
          setState((){});
        });
    }

    // Step 3: Text input (only when needed)
    if (_cmdStep == 'confirm' && (_cmdEngine == '메모' || _cmdEngine == '질문')) {
      return Container(margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(24),
        decoration:_cardDeco(Color(0xFF1A1A1A),Color(0xFFD4A574).withAlpha(50)),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          Text('${_cmdEngine == '질문' ? '무엇이든 물어보세요' : '기억할 내용'}',style:TextStyle(color:Color(0xFFD4A574),fontSize:18,fontWeight:FontWeight.w600)),
          SizedBox(height:16),
          TextField(controller:_cmdCtrl,autofocus:true,style:TextStyle(color:Colors.white),
            decoration:InputDecoration(hintText:'입력 후 ○...',hintStyle:TextStyle(color:Colors.white24),
              border:OutlineInputBorder(borderRadius:BorderRadius.circular(10)))),
        ]));
    }

    return _card('준비 중...', false);
  }

  Widget _cardFull(String title, String subtitle, {List<String>? chips, void Function(String)? onSelect}) {
    return Container(margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(24),
      decoration:_cardDeco(Color(0xFF1A1A1A),Color(0xFFD4A574).withAlpha(50)),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(title,style:TextStyle(color:Color(0xFFD4A574),fontSize:20,fontWeight:FontWeight.w600)),
        if(subtitle.isNotEmpty) Text(subtitle,style:TextStyle(color:Colors.white38,fontSize:14)),
        SizedBox(height:20),
        if(chips != null)
          Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,
            children:chips.map((c)=>ActionChip(
              label:Text(c,style:TextStyle(color:Colors.white70,fontSize:13)),
              backgroundColor:Color(0xFF1A1A1A),side:BorderSide(color:Colors.white.withAlpha(15)),
              onPressed:()=>onSelect?.call(c))).toList()),
      ]));
  }

  BoxDecoration _cardDeco(Color bg, Color border) => BoxDecoration(
    gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[bg,Color(0xFF111111),Color(0xFF0A0A0A)]),
    borderRadius:BorderRadius.circular(24),border:Border.all(color:border),
    boxShadow:[BoxShadow(color:border.withAlpha(30),blurRadius:30,offset:Offset(0,12))]);

  Widget _card(String text,bool isBack)=>Container(margin:EdgeInsets.symmetric(horizontal:16),padding:EdgeInsets.all(28),
    decoration:_cardDeco(_color,isBack?Colors.white.withAlpha(15):_color.withAlpha(100)),
    child:SingleChildScrollView(child:Text(text,textAlign:TextAlign.center,
      style:TextStyle(color:isBack?Colors.white70:Colors.white,fontSize:isBack?20:28,fontWeight:isBack?FontWeight.w400:FontWeight.w600,height:1.5))));
}