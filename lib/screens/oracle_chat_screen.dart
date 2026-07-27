import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/oracle_provider.dart';
import '../providers/ai_config_provider.dart';
import '../services/tts_service.dart';
import '../services/ai_service.dart';
/// 💬 Oracle 탭 — AI와의 컨설팅 대화
class OracleChatScreen extends StatefulWidget {
  const OracleChatScreen({super.key});

  @override
  State<OracleChatScreen> createState() => _OracleChatScreenState();
}

class _OracleChatScreenState extends State<OracleChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isOracleTyping = false;
  bool _roleSwitched = false; // false: 사용자→Oracle, true: Oracle→사용자

  @override
  void initState() {
    super.initState();
    // 첫 인사
    _messages.add(_ChatMessage(
      text: 'Hi friend!! I am your OraclePrompter. I am always with you.\n무엇을 도와드릴까요?',
      isOracle: true,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isOracle: _roleSwitched,
        timestamp: DateTime.now(),
      ));
      _isOracleTyping = true;
    });
    _controller.clear();

    // Oracle 응답 (실제 AI 서비스 사용)
    final aiConfig = context.read<AiConfigProvider>();
    final oracle = context.read<OracleProvider>();
    final tts = context.read<TtsService>();
    final service = aiConfig.service;

    if (service != null && aiConfig.isApiMode) {
      // API 모드: 실제 AI 호출
      try {
        final response = await service.chat(
          messages: [
            const AiMessage(role: 'system', content: '당신은 OraclePrompter입니다. 사용자의 대화를 돕는 AI 비서입니다. 한국어로 간결하고 도움이 되는 답변을 주세요.'),
            ..._messages.map((m) => AiMessage(
              role: m.isOracle ? 'assistant' : 'user',
              content: m.text,
            )),
            AiMessage(role: 'user', content: text),
          ],
          config: aiConfig.config,
        );

        setState(() {
          _messages.add(_ChatMessage(text: response, isOracle: !_roleSwitched, timestamp: DateTime.now()));
          _isOracleTyping = false;
        });
        oracle.receiveCoachingTip(response);
        tts.whisper(response);
      } catch (e) {
        setState(() {
          _messages.add(_ChatMessage(
            text: '(API 오류: ${e.toString()})\n\n설정에서 AI 엔진을 확인해주세요.',
            isOracle: true, timestamp: DateTime.now()));
          _isOracleTyping = false;
        });
      }
    } else {
      // 온디바이스 또는 폴백
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        final fallback = _roleSwitched
            ? '사용자님의 지적 감사합니다. 그렇게 수정하겠습니다.'
            : '좋은 질문입니다. "${oracle.currentMode.label}" 모드에서 분석 중입니다.\n\n(설정에서 API 키를 입력하시면 실제 AI 응답을 받을 수 있습니다)';

        setState(() {
          _messages.add(_ChatMessage(text: fallback, isOracle: !_roleSwitched, timestamp: DateTime.now()));
          _isOracleTyping = false;
        });
        oracle.receiveCoachingTip(text);
        tts.whisper(fallback);
      });
    }

    _scrollToBottom();
  }

  void _toggleRoleSwitch() {
    setState(() => _roleSwitched = !_roleSwitched);
    context.read<TtsService>().speak(
      _roleSwitched ? '역할 전환: Oracle이 제안하고 사용자가 코치합니다' : '역할 전환: 사용자가 묻고 Oracle이 답합니다');
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단: 역할 스위칭 + 모드
        _buildTopBar(),
        // 채팅 메시지
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_isOracleTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) return _buildTypingIndicator();
              final msg = _messages[i];
              return _buildBubble(msg);
            },
          ),
        ),
        // 입력창
        _buildInput(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.psychology, color: const Color(0xFFD4A574).withAlpha(180), size: 20),
          const SizedBox(width: 8),
          Text('Oracle 컨설팅', style: TextStyle(
            color: Colors.grey.shade300, fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          // 역할 스위칭 버튼
          GestureDetector(
            onTap: _toggleRoleSwitch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _roleSwitched
                    ? const Color(0xFF7CCE8C).withAlpha(25)
                    : const Color(0xFFD4A574).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _roleSwitched
                    ? const Color(0xFF7CCE8C).withAlpha(100)
                    : const Color(0xFFD4A574).withAlpha(100)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz, size: 14,
                    color: _roleSwitched ? const Color(0xFF7CCE8C) : const Color(0xFFD4A574)),
                  const SizedBox(width: 4),
                  Text(_roleSwitched ? '코치모드' : 'Oracle',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                      color: _roleSwitched ? const Color(0xFF7CCE8C) : const Color(0xFFD4A574))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isOracle = msg.isOracle;
    return Align(
      alignment: isOracle ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isOracle
              ? const Color(0xFF141414)
              : const Color(0xFFD4A574).withAlpha(25),
          borderRadius: BorderRadius.circular(14).copyWith(
            bottomLeft: isOracle ? const Radius.circular(4) : null,
            bottomRight: isOracle ? null : const Radius.circular(4),
          ),
          border: Border.all(color: isOracle
              ? Colors.white.withAlpha(12)
              : const Color(0xFFD4A574).withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    gradient: isOracle
                        ? const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)])
                        : const LinearGradient(colors: [Color(0xFF555555), Color(0xFF444444)]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text(isOracle ? 'O.P' : '나',
                    style: const TextStyle(color: Color(0xFF0A0A0A), fontWeight: FontWeight.w900, fontSize: 8))),
                ),
                const SizedBox(width: 6),
                Text(msg.timestamp.toString().substring(11, 16),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 6),
            Text(msg.text, style: TextStyle(
              color: Colors.white.withAlpha(220), fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(color: const Color(0xFFD4A574), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(width: 6, height: 6,
              decoration: BoxDecoration(color: const Color(0xFFD4A574).withAlpha(150), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Container(width: 6, height: 6,
              decoration: BoxDecoration(color: const Color(0xFFD4A574).withAlpha(80), borderRadius: BorderRadius.circular(3))),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(10))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: _roleSwitched ? 'Oracle에게 코치하세요...' : 'Oracle에게 물어보세요...',
                hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF141414),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.send_rounded, color: Color(0xFF0A0A0A), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String text;
  final bool isOracle;
  final DateTime timestamp;
  const _ChatMessage({required this.text, required this.isOracle, required this.timestamp});
}
