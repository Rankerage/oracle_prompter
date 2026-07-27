import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_provider.dart';

/// AI 대화 메시지
class AiMessage {
  final String role; // "user", "assistant", "system"
  final String content;
  const AiMessage({required this.role, required this.content});
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// AI 서비스 추상 클래스
abstract class AiService {
  Future<String> chat({
    required List<AiMessage> messages,
    AiProviderConfig? config,
  });

  Future<void> dispose();
}

// ──────────────────────────────────────────────
// 🔌 API 기반 AI 서비스 (OpenAI / Anthropic / DeepSeek / Gemini / Custom)
// ──────────────────────────────────────────────

class ApiAiService implements AiService {
  final http.Client _client = http.Client();

  @override
  Future<String> chat({
    required List<AiMessage> messages,
    AiProviderConfig? config,
  }) async {
    final cfg = config ?? AiProviderConfig.defaultConfig;

    switch (cfg.providerType) {
      case AiProviderType.openai:
        return _openaiChat(messages, cfg);
      case AiProviderType.anthropic:
        return _anthropicChat(messages, cfg);
      case AiProviderType.deepseek:
        return _deepseekChat(messages, cfg);
      case AiProviderType.gemini:
        return _geminiChat(messages, cfg);
      case AiProviderType.custom:
        return _customChat(messages, cfg);
      case AiProviderType.onDevice:
        throw Exception('API 모드가 아닙니다. OnDeviceAiService를 사용하세요.');
    }
  }

  Future<String> _openaiChat(List<AiMessage> messages, AiProviderConfig cfg) async {
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${cfg.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': cfg.apiModel ?? 'gpt-4o',
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': cfg.temperature,
        'max_tokens': cfg.maxTokens,
      }),
    );
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  Future<String> _anthropicChat(List<AiMessage> messages, AiProviderConfig cfg) async {
    // 시스템 메시지 분리
    final systemMsgs = messages.where((m) => m.role == 'system').map((m) => m.content).join('\n');
    final userMsgs = messages.where((m) => m.role != 'system').toList();

    final response = await _client.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': cfg.apiKey ?? '',
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': cfg.apiModel ?? 'claude-sonnet-4-20250514',
        'system': systemMsgs.isNotEmpty ? systemMsgs : null,
        'messages': userMsgs.map((m) => m.toJson()).toList(),
        'max_tokens': cfg.maxTokens,
        'temperature': cfg.temperature,
      }),
    );
    final data = jsonDecode(response.body);
    return data['content'][0]['text'] as String;
  }

  Future<String> _deepseekChat(List<AiMessage> messages, AiProviderConfig cfg) async {
    // DeepSeek is OpenAI-compatible
    final response = await _client.post(
      Uri.parse('https://api.deepseek.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${cfg.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': cfg.apiModel ?? 'deepseek-chat',
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': cfg.temperature,
        'max_tokens': cfg.maxTokens,
      }),
    );
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  Future<String> _geminiChat(List<AiMessage> messages, AiProviderConfig cfg) async {
    // Gemini는 다른 형식
    final contents = messages
        .where((m) => m.role != 'system')
        .map((m) => {
              'role': m.role == 'assistant' ? 'model' : 'user',
              'parts': [{'text': m.content}],
            })
        .toList();

    final systemMsg = messages.where((m) => m.role == 'system').firstOrNull;
    final url = systemMsg != null
        ? 'https://generativelanguage.googleapis.com/v1beta/models/${cfg.apiModel ?? 'gemini-2.5-pro-exp-03-25'}:generateContent?key=${cfg.apiKey}'
        : 'https://generativelanguage.googleapis.com/v1beta/models/${cfg.apiModel ?? 'gemini-2.5-pro-exp-03-25'}:generateContent?key=${cfg.apiKey}';

    final body = <String, dynamic>{
      'contents': contents,
    };
    if (systemMsg != null) {
      body['systemInstruction'] = {
        'parts': [{'text': systemMsg.content}],
      };
    }

    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  Future<String> _customChat(List<AiMessage> messages, AiProviderConfig cfg) async {
    // OpenAI 호환 API (Ollama, vLLM 등)
    final response = await _client.post(
      Uri.parse(cfg.customEndpoint ?? 'http://localhost:11434/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${cfg.apiKey ?? ''}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': cfg.apiModel ?? 'llama3',
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': cfg.temperature,
        'max_tokens': cfg.maxTokens,
      }),
    );
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  @override
  Future<void> dispose() async {
    _client.close();
  }
}

// ──────────────────────────────────────────────
// 📱 온디바이스 AI 서비스 (llama.cpp / MediaPipe / ONNX)
// ──────────────────────────────────────────────

class OnDeviceAiService implements AiService {
  // 실제 구현은 Flutter 플러그인을 통해 네이티브 연동
  // - llama.cpp: flutter_llama 또는 dart_llama
  // - MediaPipe: google_mlkit (Gemma)
  // - ONNX: onnxruntime

  bool _isLoaded = false;
  String? _loadedModelPath;

  /// 모델 로드 (비동기)
  Future<bool> loadModel(String modelPath, OnDeviceModel modelType) async {
    // TODO: 실제 네이티브 모델 로딩
    // 예: FlutterLlm.loadModel(modelPath)
    _loadedModelPath = modelPath;
    _isLoaded = true;
    return true;
  }

  @override
  Future<String> chat({
    required List<AiMessage> messages,
    AiProviderConfig? config,
  }) async {
    if (!_isLoaded) {
      // 모델이 로드되지 않았으면 폴백 메시지
      return '(온디바이스 모델 로딩 중입니다. 설정에서 모델을 선택해주세요.)';
    }

    // TODO: 실제 온디바이스 추론
    // final prompt = messages.map((m) => '${m.role}: ${m.content}').join('\n');
    // final response = await FlutterLlm.generate(prompt, maxTokens: config?.maxTokens ?? 512);

    return '(온디바이스 추론 결과가 여기에 표시됩니다 — 모델: ${config?.onDeviceModel?.label ?? "미선택"})';
  }

  @override
  Future<void> dispose() async {
    _isLoaded = false;
    _loadedModelPath = null;
  }
}

// ──────────────────────────────────────────────
// 🏭 AI 서비스 팩토리
// ──────────────────────────────────────────────

class AiServiceFactory {
  static AiService create(AiProviderConfig config) {
    if (config.providerType == AiProviderType.onDevice) {
      return OnDeviceAiService();
    }
    return ApiAiService();
  }
}
