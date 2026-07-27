import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/ai_provider.dart';

/// Vision API 요청 결과
class VisionAnalysis {
  final String description;
  final List<String> suggestions;
  final List<String> detectedObjects;

  const VisionAnalysis({
    required this.description,
    this.suggestions = const [],
    this.detectedObjects = const [],
  });

  factory VisionAnalysis.fromJson(Map<String, dynamic> json) {
    return VisionAnalysis(
      description: json['description'] as String? ?? '',
      suggestions: (json['suggestions'] as List?)?.cast<String>() ?? [],
      detectedObjects: (json['objects'] as List?)?.cast<String>() ?? [],
    );
  }
}

/// 👁️ Vision AI 서비스 — 카메라 이미지를 분석하여 음성 코칭 제공
class VisionService {
  final http.Client _client = http.Client();

  /// 지원하는 Vision Provider
  static const supportedProviders = [
    AiProviderType.openai,
    AiProviderType.anthropic,
    AiProviderType.gemini,
    AiProviderType.deepseek,
  ];

  /// 카메라 프레임 분석 → 코칭 메시지
  Future<VisionAnalysis> analyze(
    Uint8List imageBytes, {
    required AiProviderConfig config,
    String? context, // 현재 상황 컨텍스트
  }) async {
    switch (config.providerType) {
      case AiProviderType.openai:
        return _openaiVision(imageBytes, config, context);
      case AiProviderType.anthropic:
        return _anthropicVision(imageBytes, config, context);
      case AiProviderType.gemini:
        return _geminiVision(imageBytes, config, context);
      case AiProviderType.deepseek:
        return _deepseekVision(imageBytes, config, context);
      default:
        return const VisionAnalysis(description: 'Vision AI가 설정되지 않았습니다. OpenAI 또는 Gemini를 선택해주세요.');
    }
  }

  Future<VisionAnalysis> _openaiVision(Uint8List bytes, AiProviderConfig config, String? context) async {
    final base64 = base64Encode(bytes);
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': config.apiModel ?? 'gpt-4o',
        'messages': [{
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _buildPrompt(context)},
            {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$base64', 'detail': 'low'}},
          ],
        }],
        'max_tokens': 300,
        'temperature': 0.5,
      }),
    );

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;
    return _parseResponse(content);
  }

  Future<VisionAnalysis> _anthropicVision(Uint8List bytes, AiProviderConfig config, String? context) async {
    final base64 = base64Encode(bytes);
    final response = await _client.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': config.apiKey ?? '',
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': config.apiModel ?? 'claude-sonnet-4-20250514',
        'messages': [{
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _buildPrompt(context)},
            {'type': 'image', 'source': {
              'type': 'base64',
              'media_type': 'image/jpeg',
              'data': base64,
            }},
          ],
        }],
        'max_tokens': 300,
      }),
    );

    final data = jsonDecode(response.body);
    final content = data['content'][0]['text'] as String;
    return _parseResponse(content);
  }

  Future<VisionAnalysis> _geminiVision(Uint8List bytes, AiProviderConfig config, String? context) async {
    final base64 = base64Encode(bytes);
    final response = await _client.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/${config.apiModel ?? 'gemini-2.0-flash-exp'}:generateContent?key=${config.apiKey}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [
            {'text': _buildPrompt(context)},
            {'inline_data': {'mime_type': 'image/jpeg', 'data': base64}},
          ],
        }],
      }),
    );

    final data = jsonDecode(response.body);
    final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
    return _parseResponse(content);
  }

  Future<VisionAnalysis> _deepseekVision(Uint8List bytes, AiProviderConfig config, String? context) async {
    // DeepSeek V4 is NOT a vision model — fallback
    return const VisionAnalysis(
      description: 'DeepSeek은 Vision을 지원하지 않습니다. OpenAI 또는 Gemini를 선택해주세요.',
    );
  }

  /// 프롬프트 빌드
  String _buildPrompt(String? context) {
    return '''
당신은 OraclePrompter의 "👁️ 시선" 코치입니다.
사용자의 카메라로 보고 있는 화면을 분석하여, 1~2문장의 짧은 한국어 코칭을 제공하세요.

형식:
[설명]: 보이는 것 요약 (한 줄)
[제안]: 구체적 행동 제안 (한 줄)
[객체]: 보이는 주요 객체 쉼표로 나열

${context != null ? '현재 상황: $context' : ''}
중요: 답변은 반드시 한국어로. 3줄 이내로 간결하게.''';
  }

  /// 응답 파싱
  VisionAnalysis _parseResponse(String text) {
    final lines = text.split('\n');
    String desc = '';
    final suggestions = <String>[];
    final objects = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('[설명]') || trimmed.startsWith('설명:')) {
        desc = trimmed.replaceAll(RegExp(r'\[?설명\]?:?\s*'), '');
      } else if (trimmed.startsWith('[제안]') || trimmed.startsWith('제안:')) {
        suggestions.add(trimmed.replaceAll(RegExp(r'\[?제안\]?:?\s*'), ''));
      } else if (trimmed.startsWith('[객체]') || trimmed.startsWith('객체:')) {
        objects.addAll(trimmed.replaceAll(RegExp(r'\[?객체\]?:?\s*'), '').split(','));
      }
    }

    // 파싱 실패 시 전체 텍스트를 설명으로
    if (desc.isEmpty && suggestions.isEmpty) {
      desc = text;
    }

    return VisionAnalysis(
      description: desc,
      suggestions: suggestions,
      detectedObjects: objects,
    );
  }

  void dispose() {
    _client.close();
  }
}
