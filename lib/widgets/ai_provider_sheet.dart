import 'package:flutter/material.dart';
import '../models/ai_provider.dart';
import '../providers/ai_config_provider.dart';

/// AI Provider 선택 바텀시트
class AiProviderSheet extends StatefulWidget {
  final AiConfigProvider aiConfig;
  const AiProviderSheet({super.key, required this.aiConfig});

  @override
  State<AiProviderSheet> createState() => _AiProviderSheetState();
}

class _AiProviderSheetState extends State<AiProviderSheet> {
  late AiProviderType _selectedType;
  late String _apiKey;
  late String _apiModel;
  late String _customEndpoint;
  late OnDeviceModel _onDeviceModel;
  late double _temperature;

  @override
  void initState() {
    super.initState();
    final cfg = widget.aiConfig.config;
    _selectedType = cfg.providerType;
    _apiKey = cfg.apiKey ?? '';
    _apiModel = cfg.apiModel ?? '';
    _customEndpoint = cfg.customEndpoint ?? '';
    _onDeviceModel = cfg.onDeviceModel ?? OnDeviceModel.llama;
    _temperature = cfg.temperature;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('🧠 AI 엔진 선택', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text('온디바이스 또는 클라우드 API 중 선택하세요',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 16),

          // Provider 타입 그리드
          _buildProviderGrid(),

          const SizedBox(height: 16),

          // Provider별 상세 설정
          if (_selectedType != AiProviderType.onDevice) ...[
            _buildApiSettings(),
          ] else ...[
            _buildOnDeviceSettings(),
          ],

          const SizedBox(height: 16),

          // Temperature
          _buildTemperatureSlider(),

          const SizedBox(height: 20),

          // 적용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: const Color(0xFF0A0A0A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('적용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderGrid() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: AiProviderType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD4A574).withAlpha(30)
                  : Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected
                  ? const Color(0xFFD4A574).withAlpha(180)
                  : Colors.white.withAlpha(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.label.split(' ')[0], style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(type.label.split(' ').skip(1).join(' '),
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFD4A574) : Colors.grey.shade500,
                    fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApiSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // API 키
        Text('API 키', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          onChanged: (v) => _apiKey = v,
          controller: TextEditingController(text: _apiKey),
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'sk-... 입력하세요',
            hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0D0D0D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),

        // 모델명
        Text('모델명', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          onChanged: (v) => _apiModel = v,
          controller: TextEditingController(text: _apiModel),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: _defaultModelFor(_selectedType),
            hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0D0D0D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),

        // 커스텀 엔드포인트 (커스텀 모드일 때만)
        if (_selectedType == AiProviderType.custom) ...[
          const SizedBox(height: 12),
          Text('엔드포인트 URL', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => _customEndpoint = v,
            controller: TextEditingController(text: _customEndpoint),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'http://localhost:11434/v1',
              hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0D0D0D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOnDeviceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('온디바이스 모델', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: OnDeviceModel.values.map((model) {
            final isSelected = _onDeviceModel == model;
            return GestureDetector(
              onTap: () => setState(() => _onDeviceModel = model),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7CCE8C).withAlpha(25)
                      : Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected
                      ? const Color(0xFF7CCE8C).withAlpha(150)
                      : Colors.white.withAlpha(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(model.label, style: TextStyle(
                      color: isSelected ? const Color(0xFF7CCE8C) : Colors.grey.shade500,
                      fontWeight: FontWeight.w600, fontSize: 12)),
                    Text(model.description, style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 10)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text('인터넷 연결 없이 기기 자체에서 AI 추론',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildTemperatureSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Temperature', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(_temperature.toStringAsFixed(2),
              style: const TextStyle(color: Color(0xFFD4A574), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: _temperature,
          min: 0.0, max: 2.0,
          activeColor: const Color(0xFFD4A574),
          inactiveColor: Colors.white.withAlpha(20),
          onChanged: (v) => setState(() => _temperature = v),
        ),
        Row(
          children: [
            Text('정확', style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
            const Spacer(),
            Text('창의적', style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  String _defaultModelFor(AiProviderType type) {
    return switch (type) {
      AiProviderType.openai => 'gpt-4o',
      AiProviderType.anthropic => 'claude-sonnet-4-20250514',
      AiProviderType.deepseek => 'deepseek-chat',
      AiProviderType.gemini => 'gemini-2.5-pro-exp-03-25',
      AiProviderType.custom => 'llama3',
      _ => '',
    };
  }

  void _apply() {
    final provider = widget.aiConfig;
    if (_selectedType != AiProviderType.onDevice) {
      provider.setProviderType(_selectedType);
      if (_apiKey.isNotEmpty) provider.setApiKey(_apiKey);
      if (_apiModel.isNotEmpty) provider.setApiModel(_apiModel);
      if (_customEndpoint.isNotEmpty) provider.setCustomEndpoint(_customEndpoint);
    } else {
      provider.setOnDeviceModel(_onDeviceModel, '');
    }
    provider.setTemperature(_temperature);
    Navigator.pop(context);
  }
}
