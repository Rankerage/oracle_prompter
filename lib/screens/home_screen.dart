import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/oracle_provider.dart';
import '../providers/app_providers.dart';
import '../services/card_queue_service.dart';
import '../services/conversation_engine.dart';
import '../services/tts_service.dart';
import 'mind_screen.dart';
import 'oracle_chat_screen.dart';
import 'eye_screen.dart';
import 'journal_screen.dart';
import 'control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  static const _tabs = <Widget>[
    MindScreen(),
    OracleChatScreen(),
    EyeScreen(),
    JournalScreen(),
    ControlScreen(),
  ];

  final CardQueueService _cardQueue = CardQueueService();
  late ConversationEngine _engine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final graph = context.read<MindGraphProvider>();
      final oracle = context.read<OracleProvider>();
      final tts = context.read<TtsService>();
      _engine = ConversationEngine(graph: graph, oracle: oracle, tts: tts);
      _cardQueue.start(context, onGraphNode: (label, type) {
        graph.addLiveNode(label, type);
      });
      // Demo: seed initial MindGraph
      _engine.onUtterance('안녕하세요 OraclePrompter');
      _engine.onUtterance('오늘 회의에서 프로젝트 방향을 논의했어요');
      _engine.onUtterance('친구가 요즘 운동을 시작했대요');
    });
  }

  @override
  void dispose() {
    _cardQueue.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final oracle = context.watch<OracleProvider>();
    final journal = context.watch<JournalProvider>();

    return Scaffold(
      // 상단 상태바
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: oracle.isActive
                      ? [const Color(0xFFD4A574), const Color(0xFFE8C97A)]
                      : [Colors.grey.shade600, Colors.grey.shade500],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: Text('O.P', style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                )),
              ),
            ),
            const SizedBox(width: 10),
            // 활성화 인디케이터
            if (oracle.isActive)
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: const Color(0xFFD4A574).withAlpha(200),
                    blurRadius: 6,
                  )],
                ),
              ),
          ],
        ),
        actions: [
          // 세션 표시
          if (journal.activeSessionId != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A574).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red.shade400, size: 8),
                  const SizedBox(width: 4),
                  Text('REC', style: TextStyle(
                    color: const Color(0xFFD4A574),
                    fontSize: 10, fontWeight: FontWeight.bold,
                  )),
                ],
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withAlpha(10))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bubble_chart),
              activeIcon: Icon(Icons.bubble_chart, size: 28),
              label: '마인드',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              activeIcon: Icon(Icons.psychology, size: 28),
              label: 'Oracle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.remove_red_eye_outlined),
              activeIcon: Icon(Icons.remove_red_eye, size: 28),
              label: '시선',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              activeIcon: Icon(Icons.menu_book, size: 28),
              label: '기록',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune),
              activeIcon: Icon(Icons.tune, size: 28),
              label: '제어',
            ),
          ],
        ),
      ),
    );
  }
}
