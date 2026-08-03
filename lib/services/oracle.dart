import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🔮 Oracle Engine — 델포이 신탁
///
/// 어떤 질문이든 받아서 AI 답변을 카드로 반환.
/// TikiTaka Pantheon의 여섯 번째 엔진.
class Oracle {
  static final Oracle _i = Oracle._();
  factory Oracle() => _i;
  Oracle._();

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _key = 'YOUR_OPENROUTER_KEY'; // Cloudflare Worker 배포 전까진 직접
  static const _model = 'openai/gpt-oss-20b:free';

  // ─── Ask anything ───────────────────────────────

  Future<Map<String, String>> ask(String question) async {
    try {
      final res = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': '짧고 명확하게 한국어로 답변하세요. 카드 형식으로 보여질 답변입니다. 3-4문장으로.'},
            {'role': 'user', 'content': question},
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final answer = data['choices'][0]['message']['content'].toString().trim();
        return {'front': question, 'back': answer};
      }
      return {'front': question, 'back': '죄송합니다. 답변을 생성할 수 없습니다.'};
    } catch (_) {
      return {'front': question, 'back': '연결이 원활하지 않습니다. 잠시 후 다시 시도해주세요.'};
    }
  }

  /// Offline fallback answers
  Map<String, String> askOffline(String question) {
    final q = question.toLowerCase();
    String answer;
    if (q.contains('오늘') && (q.contains('날씨') || q.contains('날'))) {
      answer = '날씨 정보는 인터넷 연결이 필요합니다. 연결을 확인해주세요.';
    } else if (q.contains('뭐') || q.contains('누구') || q.contains('어디')) {
      answer = '아직 배우는 중입니다. 인터넷에 연결되면 더 정확한 답변을 드릴 수 있어요.';
    } else {
      answer = '지금은 인터넷 연결이 필요합니다. 오프라인에서는 학습 카드를 이용해보세요.';
    }
    return {'front': question, 'back': answer};
  }
}
