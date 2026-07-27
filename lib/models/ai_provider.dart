/// AI Provider 종류
enum AiProviderType {
  /// 온디바이스 — llama.cpp, MediaPipe, Gemma 등
  onDevice('📱 온디바이스', '인터넷 없이 로컬 AI'),

  /// OpenAI API (GPT-4o, o3 등)
  openai('🤖 OpenAI', 'GPT-4o · o3'),

  /// Anthropic API (Claude)
  anthropic('🧠 Anthropic', 'Claude Sonnet · Opus'),

  /// DeepSeek API
  deepseek('🔮 DeepSeek', 'DeepSeek V4 · R1'),

  /// Google Gemini API
  gemini('🌐 Gemini', 'Gemini 2.5 Pro'),

  /// 커스텀 엔드포인트 (Ollama, vLLM 등)
  custom('⚙️ 커스텀', 'Ollama · vLLM · 자체 서버');

  final String label;
  final String description;

  const AiProviderType(this.label, this.description);
}

/// 온디바이스 모델 종류
enum OnDeviceModel {
  /// llama.cpp — GGUF 모델 (범용)
  llama('Llama.cpp', 'GGUF 범용 모델', '.gguf'),

  /// Google Gemma (MediaPipe)
  gemma('Gemma 3', 'Google 경량 모델', '.tflite'),

  /// Microsoft Phi (ONNX)
  phi('Phi-4', 'Microsoft 경량 모델', '.onnx'),

  /// MLX (Apple Silicon 전용)
  mlx('MLX', 'Apple Silicon 최적화', '.mlx');

  final String label;
  final String description;
  final String extension;

  const OnDeviceModel(this.label, this.description, this.extension);
}

/// AI Provider 설정
class AiProviderConfig {
  final AiProviderType providerType;
  final OnDeviceModel? onDeviceModel;
  final String? onDeviceModelPath;
  final String? apiKey;
  final String? apiModel; // 예: "gpt-4o", "claude-sonnet-4"
  final String? customEndpoint;
  final double temperature;
  final int maxTokens;

  const AiProviderConfig({
    this.providerType = AiProviderType.onDevice,
    this.onDeviceModel,
    this.onDeviceModelPath,
    this.apiKey,
    this.apiModel,
    this.customEndpoint,
    this.temperature = 0.7,
    this.maxTokens = 1024,
  });

  /// 기본값: 온디바이스
  static const defaultConfig = AiProviderConfig();

  /// DeepSeek API (Nous 구독)
  static const deepseekDefault = AiProviderConfig(
    providerType: AiProviderType.deepseek,
    apiModel: 'deepseek-chat',
    temperature: 0.7,
  );

  /// OpenAI API
  static const openaiDefault = AiProviderConfig(
    providerType: AiProviderType.openai,
    apiModel: 'gpt-4o',
    temperature: 0.7,
  );

  Map<String, dynamic> toJson() => {
        'providerType': providerType.name,
        'onDeviceModel': onDeviceModel?.name,
        'onDeviceModelPath': onDeviceModelPath,
        'apiKey': apiKey,
        'apiModel': apiModel,
        'customEndpoint': customEndpoint,
        'temperature': temperature,
        'maxTokens': maxTokens,
      };

  factory AiProviderConfig.fromJson(Map<String, dynamic> json) {
    return AiProviderConfig(
      providerType: AiProviderType.values.firstWhere(
        (t) => t.name == json['providerType'],
        orElse: () => AiProviderType.onDevice,
      ),
      onDeviceModel: json['onDeviceModel'] != null
          ? OnDeviceModel.values.firstWhere((m) => m.name == json['onDeviceModel'])
          : null,
      onDeviceModelPath: json['onDeviceModelPath'],
      apiKey: json['apiKey'],
      apiModel: json['apiModel'],
      customEndpoint: json['customEndpoint'],
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 1024,
    );
  }
}
