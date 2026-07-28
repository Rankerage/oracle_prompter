import 'package:flutter/material.dart';
import '../models/mind_graph.dart';
import '../providers/app_providers.dart';
import '../providers/oracle_provider.dart';
import '../services/tts_service.dart';
import '../services/card_optimizer.dart';
import '../services/card_queue_service.dart';

/// 🧠 Unified Conversation Engine
///
/// 모든 대화 모드(대면, 통화, Oracle 채팅)에서
/// 마인드그래프 + 시뮬레이션 + 리매핑 + 음성코치를 통합 처리.
class ConversationEngine {
  final MindGraphProvider _graph;
  final OracleProvider _oracle;
  final TtsService? _tts;

  ConversationEngine({
    required MindGraphProvider graph,
    required OracleProvider oracle,
    TtsService? tts,
  })  : _graph = graph,
        _oracle = oracle,
        _tts = tts;

  // ─── Input from any conversation source ────────

  /// New utterance received (from STT, chat, or simulated)
  void onUtterance(String text, {String? speaker, double confidence = 1.0}) {
    // 1. Extract keywords → MindGraph nodes
    final keywords = _extractKeywords(text);
    for (final kw in keywords) {
      _graph.addLiveNode(kw.word, kw.type);
    }

    // 2. Run force simulation tick for smooth animation
    _graph.simulationTick();

    // 3. Generate predicted next nodes
    if (keywords.isNotEmpty) {
      final lastNode = _graph.nodes.isNotEmpty ? _graph.nodes.last.id : null;
      if (lastNode != null) {
        _graph.addPredictedNode(keywords.last.word + '?', lastNode);
      }
    }

    // 4. Remap to topics (keyword → topic classification)
    final topic = _remapToTopic(keywords);
    if (topic != null) {
      _oracle.receiveCoachingTip('주제: $topic');
    }

    // 5. Voice coach if appropriate
    if (_shouldCoach(text)) {
      final tip = _generateTip(text, keywords);
      if (tip != null && _tts != null) {
        _oracle.receiveCoachingTip(tip);
        _tts!.whisper(tip);
        // Signal optimizer that coaching happened
        CardOptimizer().onCoachingEvent();
      }
    }
  }

  // ─── Keyword Extraction ────────────────────────

  List<_Keyword> _extractKeywords(String text) {
    final results = <_Keyword>[];
    final words = text.split(RegExp(r'[\s,.!?]+'));

    // Simple keyword detection based on word length and common patterns
    for (final word in words) {
      if (word.length < 2) continue;

      NodeType type = NodeType.concept;
      if (_isQuestionWord(word)) type = NodeType.question;
      else if (_isEmotionWord(word)) type = NodeType.emotion;
      else if (_isActionWord(word)) type = NodeType.action;
      else if (word.length >= 4) type = NodeType.keyword;

      results.add(_Keyword(word: word, type: type));
    }
    return results.take(5).toList(); // Limit to 5 nodes per utterance
  }

  bool _isQuestionWord(String w) => ['뭐', '왜', '어떻게', '언제', '어디', '누가'].contains(w);
  bool _isEmotionWord(String w) => ['기쁘', '슬프', '화나', '좋', '싫', '행복', '걱정', '스트레스'].any((e) => w.contains(e));
  bool _isActionWord(String w) => ['하자', '가자', '만나', '회의', '약속', '준비', '완료'].any((e) => w.contains(e));

  // ─── Topic Remapping ───────────────────────────

  final _topicMap = {
    '회의': '업무', '프로젝트': '업무', '일정': '업무', '발표': '업무',
    '친구': '관계', '가족': '관계', '연락': '관계',
    '운동': '건강', '병원': '건강', '식단': '건강',
    '공부': '학습', '책': '학습', '강의': '학습',
    '여행': '이동', '출장': '이동',
  };

  String? _remapToTopic(List<_Keyword> keywords) {
    for (final kw in keywords) {
      for (final entry in _topicMap.entries) {
        if (kw.word.contains(entry.key)) return entry.value;
      }
    }
    return null;
  }

  // ─── Coaching ──────────────────────────────────

  bool _shouldCoach(String text) {
    // Don't coach on very short utterances
    if (text.length < 10) return false;
    // Don't coach if recently coached (avoid spam)
    final lastTip = _oracle.lastCoachingTip;
    if (lastTip != null) return false;
    return true;
  }

  String? _generateTip(String text, List<_Keyword> keywords) {
    if (keywords.isEmpty) return null;

    // Generate contextual tip based on detected keywords
    final hasQuestion = keywords.any((k) => k.type == NodeType.question);
    final hasEmotion = keywords.any((k) => k.type == NodeType.emotion);

    if (hasQuestion) return '질문이 감지되었어요. 천천히 답변해보세요.';
    if (hasEmotion) return '감정이 담긴 대화네요. 공감해주세요.';
    return null;
  }
}

class _Keyword {
  final String word;
  final NodeType type;
  const _Keyword({required this.word, required this.type});
}
