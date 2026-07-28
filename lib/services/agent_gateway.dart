import '../widgets/conversation_card.dart';
import 'package:flutter/material.dart';

/// 🔗 Agent Gateway — O.P delegates work to other agents
///
/// User never leaves O.P. O.P routes tasks to the right agent,
/// gets the result, and delivers it back via card.
class AgentGateway {
  static final AgentGateway _i = AgentGateway._();
  factory AgentGateway() => _i;
  AgentGateway._();

  // ─── Registered agents ─────────────────────────

  final Map<String, _AgentConfig> _agents = {};

  void register(String name, _AgentConfig config) => _agents[name] = config;

  // ─── Route task to best agent ──────────────────

  Future<String?> delegate({
    required String task,
    required BuildContext context,
  }) async {
    final agent = _routeAgent(task);
    if (agent == null) return null;

    // Show card: "코딩은 Hermes Agent에게 맡길까요?"
    final result = await _askUser(context, agent, task);
    if (result == null) return null;

    // Execute via agent's protocol
    return _execute(agent, task);
  }

  _AgentConfig? _routeAgent(String task) {
    final lower = task.toLowerCase();

    // Coding → coding agent
    if (_matches(lower, ['코드', '프로그래밍', '앱', '개발', '웹사이트', '버그', '빌드'])) {
      return _agents['coder'] ?? _AgentConfig(
        name: 'Coding Agent',
        description: '코드 작성과 디버깅을 전문으로 하는 에이전트',
        endpoint: 'https://api.openrouter.ai/v1/chat/completions',
        model: 'anthropic/claude-sonnet-4',
      );
    }

    // Research → research agent
    if (_matches(lower, ['검색', '조사', '리서치', '찾아', '알아봐', '분석'])) {
      return _agents['researcher'] ?? _AgentConfig(
        name: 'Research Agent',
        description: '웹 검색과 자료 조사를 전문으로 하는 에이전트',
        endpoint: 'https://api.openrouter.ai/v1/chat/completions',
        model: 'perplexity/llama-3.1-sonar-large',
      );
    }

    // General → default agent
    return _agents['general'] ?? _AgentConfig(
      name: 'General Agent',
      description: '일반적인 질문과 업무를 처리하는 에이전트',
      endpoint: 'https://api.openrouter.ai/v1/chat/completions',
      model: 'deepseek/deepseek-chat',
    );
  }

  bool _matches(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  // ─── User confirmation via card ─────────────────

  Future<bool?> _askUser(BuildContext ctx, _AgentConfig agent, String task) {
    final completer = Completer<bool?>();
    showCard(ctx,
      type: CardType.preference,
      statement: '${agent.name}에게 "${_shorten(task)}" 작업을 맡길까요?',
      backAnswer: '${agent.description}\n\n잠시 후 결과를 카드로 보여드릴게요.',
      pos: '맡기기', neg: '취소',
      onResult: (c) => completer.complete(c >= 1),
    );
    return completer.future;
  }

  // ─── Execute via agent protocol ─────────────────

  Future<String?> _execute(_AgentConfig agent, String task) {
    // Options per agent type:
    // 1. OpenRouter API call (simplest)
    // 2. Local Hermes Agent via HTTP (if on same network)
    // 3. Kimi Claw webhook (if deployed)
    // 4. SSH to desktop agent

    // Default: OpenRouter API
    return _callOpenRouter(agent, task);
  }

  Future<String> _callOpenRouter(_AgentConfig agent, String task) async {
    // Simplified — real implementation uses http package
    return '${agent.name}가 작업을 완료했어요.\n\n결과를 카드로 보여드릴게요.\n\n(API 연동 필요)';
  }

  String _shorten(String text) => text.length > 30 ? '${text.substring(0, 28)}...' : text;
}

class _AgentConfig {
  final String name, description, endpoint, model;
  const _AgentConfig({required this.name, required this.description,
      required this.endpoint, required this.model});
}

/// Quick API: user asks anything, O.P routes to agent
void askAgent(BuildContext ctx, String task) {
  AgentGateway().delegate(task: task, context: ctx);
}
