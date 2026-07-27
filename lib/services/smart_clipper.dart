import 'dart:math';
import '../services/ai_service.dart';
import '../models/ai_provider.dart';

/// 🧠 Intelligent Clipping — AI가 중요한 순간을 판단하고 오려냄
class SmartClipper {
  final AiService? _ai;

  SmartClipper({AiService? ai}) : _ai = ai;

  /// Analyze transcript and find important moments
  /// Returns list of (startSec, endSec, label, importance 0-1)
  Future<List<_ClipMoment>> findImportantMoments(
    String transcript, {
    AiProviderConfig? config,
  }) async {
    // If LLM is available, use it for smart analysis
    if (_ai != null && config != null && config.providerType != AiProviderType.onDevice) {
      return _aiAnalyze(transcript, config);
    }

    // Fallback: heuristic-based detection (works without LLM)
    return _heuristicAnalyze(transcript);
  }

  /// LLM-based analysis
  Future<List<_ClipMoment>> _aiAnalyze(String transcript, AiProviderConfig config) async {
    try {
      final response = await _ai!.chat(
        messages: [
          AiMessage(role: 'system',
            content: '''Analyze this conversation transcript. Find the MOST IMPORTANT moments.

Return JSON array only:
[{"start": "keyword or phrase that marks the start", "end": "keyword marking end", "label": "short label in Korean", "importance": 0.0-1.0}]

Rules:
- Maximum 5 moments
- Only moments with importance > 0.5
- Labels in Korean, 2-5 words
- 중요: 결정, 감정, 새로운 정보, 약속, 갈등'''),
          AiMessage(role: 'user', content: transcript),
        ],
        config: config,
      );

      return _parseAiResponse(response);
    } catch (e) {
      return _heuristicAnalyze(transcript);
    }
  }

  /// Heuristic fallback (no LLM needed)
  List<_ClipMoment> _heuristicAnalyze(String text) {
    final moments = <_ClipMoment>[];
    final sentences = text.split(RegExp(r'[.!?]+'));

    for (int i = 0; i < sentences.length; i++) {
      final s = sentences[i].trim();
      if (s.length < 5) continue;

      double importance = 0.3; // base

      // Emotion words → higher importance
      if (RegExp(r'기쁘|슬프|화나|좋아|싫어|행복|걱정|스트레스|놀라').hasMatch(s))
        importance += 0.3;

      // Decision/action words
      if (RegExp(r'하자|결정|약속|꼭|반드시|계약|합의|확정').hasMatch(s))
        importance += 0.3;

      // New information markers
      if (RegExp(r'새로|처음|알았|몰랐|새로운|발표').hasMatch(s))
        importance += 0.2;

      // Long sentence = probably important
      if (s.length > 30) importance += 0.1;

      if (importance > 0.5) {
        moments.add(_ClipMoment(
          startSec: i * 3.0, // rough estimate: ~3 seconds per sentence
          endSec: (i + 1) * 3.0,
          label: s.length > 20 ? '${s.substring(0, 15)}...' : s,
          importance: importance.clamp(0.0, 1.0),
        ));
      }
    }

    return moments.take(5).toList();
  }

  List<_ClipMoment> _parseAiResponse(String json) {
    // Simple JSON array parsing
    try {
      final results = <_ClipMoment>[];
      final matches = RegExp(r'\{"start":"([^"]+)","end":"([^"]+)","label":"([^"]+)","importance":([0-9.]+)\}').allMatches(json);
      for (final m in matches) {
        results.add(_ClipMoment(
          startSec: m.group(1)?.length.toDouble() ?? 0,
          endSec: m.group(2)?.length.toDouble() ?? 5,
          label: m.group(3) ?? '중요 순간',
          importance: double.tryParse(m.group(4) ?? '0.5') ?? 0.5,
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  }
}

class _ClipMoment {
  final double startSec;
  final double endSec;
  final String label;
  final double importance;
  const _ClipMoment({
    required this.startSec, required this.endSec,
    required this.label, required this.importance,
  });
}
