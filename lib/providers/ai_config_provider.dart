import 'package:flutter/material.dart';
import '../models/ai_provider.dart';
import '../services/ai_service.dart';

/// AI Provider 설정 상태 관리
class AiConfigProvider extends ChangeNotifier {
  AiProviderConfig _config = AiProviderConfig.defaultConfig;
  AiService? _service;
  bool _isLoading = false;

  // O.P built-in proxy — no user setup needed
  static const _proxyUrl = 'https://tikitaka-proxy.rankerage.workers.dev/chat';

  AiConfigProvider() {
    // Start with built-in proxy. User never sees "API" word.
    _switchToProvider(AiProviderType.deepseek);
  }

  AiProviderConfig get config => _config;
  AiService? get service => _service;
  bool get isLoading => _isLoading;
  bool get isApiMode => _config.providerType != AiProviderType.onDevice;

  /// Provider 타입 변경
  Future<void> setProviderType(AiProviderType type) async {
    _isLoading = true;
    notifyListeners();

    await _service?.dispose();

    _config = AiProviderConfig(
      providerType: type,
      onDeviceModel: _config.onDeviceModel,
      onDeviceModelPath: _config.onDeviceModelPath,
      apiKey: _config.apiKey,
      apiModel: _config.apiModel,
      customEndpoint: _config.customEndpoint,
      temperature: _config.temperature,
      maxTokens: _config.maxTokens,
    );

    _service = AiServiceFactory.create(_config);

    _isLoading = false;
    notifyListeners();
  }

  /// API 키 설정
  void setApiKey(String key) {
    _config = AiProviderConfig(
      providerType: _config.providerType,
      onDeviceModel: _config.onDeviceModel,
      onDeviceModelPath: _config.onDeviceModelPath,
      apiKey: key,
      apiModel: _config.apiModel,
      customEndpoint: _config.customEndpoint,
      temperature: _config.temperature,
      maxTokens: _config.maxTokens,
    );
    _service = AiServiceFactory.create(_config);
    notifyListeners();
  }

  /// API 모델명 설정
  void setApiModel(String model) {
    _config = AiProviderConfig(
      providerType: _config.providerType,
      onDeviceModel: _config.onDeviceModel,
      onDeviceModelPath: _config.onDeviceModelPath,
      apiKey: _config.apiKey,
      apiModel: model,
      customEndpoint: _config.customEndpoint,
      temperature: _config.temperature,
      maxTokens: _config.maxTokens,
    );
    _service = AiServiceFactory.create(_config);
    notifyListeners();
  }

  /// 온디바이스 모델 설정
  void setOnDeviceModel(OnDeviceModel model, String path) {
    _config = AiProviderConfig(
      providerType: AiProviderType.onDevice,
      onDeviceModel: model,
      onDeviceModelPath: path,
    );
    _service = AiServiceFactory.create(_config);
    notifyListeners();
  }

  /// 커스텀 엔드포인트 설정
  void setCustomEndpoint(String endpoint) {
    _config = AiProviderConfig(
      providerType: _config.providerType,
      onDeviceModel: _config.onDeviceModel,
      onDeviceModelPath: _config.onDeviceModelPath,
      apiKey: _config.apiKey,
      apiModel: _config.apiModel,
      customEndpoint: endpoint,
      temperature: _config.temperature,
      maxTokens: _config.maxTokens,
    );
    _service = AiServiceFactory.create(_config);
    notifyListeners();
  }

  /// Temperature 조절
  void setTemperature(double t) {
    _config = AiProviderConfig(
      providerType: _config.providerType,
      onDeviceModel: _config.onDeviceModel,
      onDeviceModelPath: _config.onDeviceModelPath,
      apiKey: _config.apiKey,
      apiModel: _config.apiModel,
      customEndpoint: _config.customEndpoint,
      temperature: t,
      maxTokens: _config.maxTokens,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}
