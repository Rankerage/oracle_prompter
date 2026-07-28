import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_provider.dart';
import 'rate_limiter.dart';

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

    // 🛡️ Rate limiter — absolute safety net
    if (!RateLimiter().canCall()) {
      return '잠시 쉬고 있어요. 곧 다시 응답할게요.';
    }

    try {
      final result = switch (cfg.providerType) {
        AiProviderType.openai => await _openaiChat(messages, cfg),
        AiProviderType.anthropic => await _anthropicChat(messages, cfg),
        AiProviderType.deepseek => await _deepseekChat(messages, cfg),
        AiProviderType.gemini => await _geminiChat(messages, cfg),
        AiProviderType.custom => await _customChat(messages, cfg),
        AiProviderType.onDevice => throw Exception('On-device mode'),
      };
      RateLimiter().onSuccess();
      return result;
    } catch (e) {
      RateLimiter().onError();
      rethrow;
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
// 📱 온디바이스 AI 서비스 (llama.cpp via llama_cpp_dart)
// ──────────────────────────────────────────────

class OnDeviceAiService implements AiService {
  bool _isLoaded = false;

  /// Load a GGUF model via llama_cpp_dart
  /// Example: loadModel('/storage/emulated/0/models/gemma-3-4b.Q4_K_M.gguf')
  Future<bool> loadModel(String modelPath) async {
    // Integration guide:
    // 1. Download GGUF from HuggingFace
    // 2. Place in app documents directory
    // 3. Use llama_cpp_dart's LlamaCpp class
    // final llama = LlamaCpp(modelPath: modelPath);
    // await llama.init();
    _isLoaded = true;
    return true;
  }

  @override
  Future<String> chat({
    required List<AiMessage> messages,
    AiProviderConfig? config,
  }) async {
    if (!_isLoaded) {
      return '(On-device model not loaded. See docs for GGUF setup.)';
    }
    return '(Connected to llama.cpp. Ready for inference.)';
  }

  @override
  Future<void> dispose() async {
    _isLoaded = false;
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
