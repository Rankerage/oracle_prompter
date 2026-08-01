import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ai_config_provider.dart';
import 'widgets/conversation_card.dart';
import 'widgets/subject_picker.dart';
import 'services/slash_commands.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TikiTakaApp());
}

class TikiTakaApp extends StatelessWidget {
  const TikiTakaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiConfigProvider(),
      child: MaterialApp(
        title: 'TikiTaka',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4A574), brightness: Brightness.dark),
        ),
        home: const TikiTakaScreen(),
      ),
    );
  }
}

class TikiTakaScreen extends StatefulWidget {
  const TikiTakaScreen({super.key});
  @override State<TikiTakaScreen> createState() => _TikiTakaScreenState();
}

class _TikiTakaScreenState extends State<TikiTakaScreen> {
  bool _userTurn = false; // ▼=AI asking, ▲=user asking
  final _recent = <String>[];

  static const _quickActions = [
    '영어 단어 공부 시작해줘',
    '오늘의 유머 보여줘',
    'IT 신조어 알려줘',
    '볼륨 조절',
    '학습 통계 보여줘',
  ];

  void _toggleTurn() {
    setState(() => _userTurn = !_userTurn);
    _showCard();
  }

  void _showCard({String? customStatement}) {
    final statement = customStatement ??
        (_userTurn ? '무엇을 도와드릴까요?\n말씀하시거나 아래에서 선택하세요.'
                   : 'AI와 티키타카, 시작해볼까요?');
    final back = _userTurn
        ? '요청하신 내용을 처리했어요. 더 필요하신 게 있으세요?'
        : '○는 긍정, ✕는 부정.\n▲는 질문, ▼는 AI가 대화를 이끌어요.';

    showGeneralDialog(
      context: context, barrierDismissible: false, barrierLabel: '',
      barrierColor: Colors.black87,
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim, __, child) {
        return FadeTransition(opacity: anim, child: Center(
          child: ConversationCard(
            type: _userTurn ? CardType.askMe : CardType.preference,
            statement: statement, backAnswer: back,
            flow: CardFlow.tutorial,
            isUserTurn: _userTurn,
            positiveLabel: '○', negativeLabel: '✕',
            onDismiss: () {
              if (!_userTurn) {
                setState(() => _userTurn = !_userTurn);
              }
            },
            onResult: (_) {},
          ),
        ));
      },
    );
  }

  void _onQuickAction(String action) {
    _recent.insert(0, action);
    if (_recent.length > 5) _recent.removeLast();
    SlashCommands.handle('/$action', context);
    _showCard(customStatement: '$action 했어요.');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () => _showCard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              // Header
              const SizedBox(height: 48),
              const Text('🃏 TikiTaka',
                  style: TextStyle(color: Color(0xFFD4A574), fontSize: 28, fontWeight: FontWeight.w900)),
              const Text('AI가 먼저 톡. 당신은 그냥 탭.',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 32),

              // Triangle toggle
              GestureDetector(
                onTap: _toggleTurn,
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(10),
                    border: Border.all(color: (_userTurn ? const Color(0xFFD4A574) : Colors.white24)),
                  ),
                  child: Center(child: Text(_userTurn ? '▲' : '▼',
                      style: TextStyle(color: _userTurn ? const Color(0xFFD4A574) : Colors.white38, fontSize: 28))),
                ),
              ),
              const SizedBox(height: 4),
              Text(_userTurn ? '내가 질문하기' : 'AI가 말 걸기',
                  style: TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(height: 28),

              // Start button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A574),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showCard(),
                child: const Text('시작하기', style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 32),

              // Quick actions
              const Text('자주 묻는 요청', style: TextStyle(color: Colors.white30, fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: _quickActions.map((a) =>
                ActionChip(
                  label: Text(a, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  backgroundColor: const Color(0xFF1A1A1A),
                  side: BorderSide(color: Colors.white.withAlpha(15)),
                  onPressed: () => _onQuickAction(a),
                )).toList()),
              const SizedBox(height: 20),

              // Recent
              if (_recent.isNotEmpty) ...[
                const Text('최근 요청', style: TextStyle(color: Colors.white24, fontSize: 11)),
                const SizedBox(height: 6),
                ..._recent.map((r) => GestureDetector(
                  onTap: () => _onQuickAction(r),
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(r, style: const TextStyle(color: Colors.white38, fontSize: 12))))),
              ],
              const Spacer(),

              // Footer
              const Padding(padding: EdgeInsets.only(bottom: 24),
                child: Text('✕ = tiki  |  ○ = taka',
                    style: TextStyle(color: Colors.white12, fontSize: 11))),
            ]),
          ),
        ),
      ),
    );
  }
}
