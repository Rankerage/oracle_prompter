/// 🧠 OnDeviceLLM — 오프라인 AI 두뇌
///
/// llama_cpp_dart + GGUF 모델.
/// 사용자가 모델을 별도 다운로드. APK에 포함 안 함.
class OnDeviceLLM {
  static final OnDeviceLLM _i = OnDeviceLLM._();
  factory OnDeviceLLM() => _i;
  OnDeviceLLM._();

  // status: none | downloading | ready | error
  String _modelStatus = 'none';
  double _downloadProgress = 0;

  // ─── Available models ──────────────────────────

  static const _models = {
    'exaone-2.4b': {
      'name': 'EXAONE 2.4B (LG)',
      'desc': '한국어 최적화. 1.5GB.',
      'url': 'https://huggingface.co/LGAI/EXAONE-3.0-2.4B-Instruct-GGUF',
      'size': '1.5GB',
      'file': 'exaone-2.4b-q4.gguf',
    },
    'gemma-2b': {
      'name': 'Gemma 2B (Google)',
      'desc': '다국어. 가장 빠름. 1.5GB.',
      'url': 'https://huggingface.co/google/gemma-2b-it-GGUF',
      'size': '1.5GB',
      'file': 'gemma-2b-q4.gguf',
    },
  };

  // ─── API ───────────────────────────────────────

  Map<String, Map<String, String>> get availableModels => _models;

  String get status => _modelStatus;
  double get progress => _downloadProgress;
  bool get isReady => _modelStatus == 'ready';

  /// Start downloading a model
  Future<void> downloadModel(String key) async {
    _modelStatus = 'downloading';
    _downloadProgress = 0;

    // TODO: 실제 다운로드 구현
    // 1. http.get(url) with progress tracking
    // 2. Save to app's internal storage
    // 3. Verify checksum
    // 4. Set status = 'ready'

    _modelStatus = 'ready';
    _downloadProgress = 1.0;
  }

  /// Ask the on-device model
  Future<String> ask(String question) async {
    if (!isReady) return '모델이 아직 준비되지 않았습니다.';

    // TODO: llama_cpp_dart 호출
    // final llm = Llama(modelPath, contextSize: 512);
    // final answer = await llm.prompt(question);
    // return answer;

    return '오프라인 모델 응답: $question 에 대한 답변입니다.';
  }

  /// Delete model to free space
  Future<void> deleteModel() async {
    _modelStatus = 'none';
    _downloadProgress = 0;
  }

  void dispose() {}
}
