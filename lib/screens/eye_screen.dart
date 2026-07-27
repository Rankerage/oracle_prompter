import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/oracle_provider.dart';
import '../providers/ai_config_provider.dart';
import '../services/vision_service.dart';
import '../services/tts_service.dart';
import '../services/phone_intelligence.dart';
import '../models/ai_provider.dart';

/// 👁️ 시선 탭 — 카메라로 사용자 시야 공유, AI 실시간 코칭
class EyeScreen extends StatefulWidget {
  const EyeScreen({super.key});

  @override
  State<EyeScreen> createState() => _EyeScreenState();
}

class _EyeScreenState extends State<EyeScreen> with WidgetsBindingObserver {
  CameraController? _camera;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0; // 0=후면, 1=전면
  bool _isAnalyzing = false;
  Timer? _analysisTimer;
  final VisionService _vision = VisionService();
  final ScreenCaptureService _screenCapture = ScreenCaptureService();
  String? _lastCoachingTip;
  String? _lastDescription;
  bool _isActive = false;
  bool _isScreenMode = false; // false=카메라, true=화면캡처

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _camera = CameraController(_cameras[_cameraIndex], ResolutionPreset.medium,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
        await _camera!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _toggleActive() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _startAnalysis();
        context.read<TtsService>().whisper('시선 모드 활성화. 함께 보고 코칭을 시작합니다.');
      } else {
        _stopAnalysis();
        context.read<TtsService>().whisper('시선 모드 종료.');
      }
    });
  }

  void _startAnalysis() {
    _analysisTimer?.cancel();
    if (_isScreenMode) {
      _screenCapture.startCapture(
        onFrame: _analyzeFrame,
        intervalMs: 4000,
      );
      // 첫 분석
      Future.delayed(const Duration(seconds: 1), () => _analyzeScreenFrame());
    } else {
      _analysisTimer = Timer.periodic(const Duration(seconds: 4), (_) => _captureAndAnalyze());
      _captureAndAnalyze();
    }
  }

  void _stopAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _screenCapture.stopCapture();
  }

  void _analyzeFrame(Uint8List bytes) {
    // 화면 캡처 모드: bytes로 분석 실행
    _runVisionAnalysis(bytes);
  }

  Future<void> _analyzeScreenFrame() async {
    // Placeholder for screen frame analysis
  }

  void _toggleMode() {
    if (_isActive) _stopAnalysis();
    setState(() => _isScreenMode = !_isScreenMode);
    if (_isActive) {
      Future.delayed(const Duration(milliseconds: 500), _startAnalysis);
    }
    context.read<TtsService>().whisper(
      _isScreenMode ? '화면 공유 모드. 폰 화면을 함께 봅니다.' : '카메라 모드. 시야를 함께 봅니다.');
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isActive || _camera == null || !_camera!.value.isInitialized || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    try {
      final image = await _camera!.takePicture();
      final bytes = await image.readAsBytes();
      await _runVisionAnalysis(bytes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastCoachingTip = '분석 실패: ${e.toString().substring(0, 50)}...';
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _runVisionAnalysis(Uint8List bytes) async {
    final aiConfig = context.read<AiConfigProvider>();

    if (!VisionService.supportedProviders.contains(aiConfig.config.providerType)) {
      setState(() {
        _lastCoachingTip = 'Vision을 지원하는 AI 엔진으로 변경해주세요\n(OpenAI, Claude, Gemini)';
        _isAnalyzing = false;
      });
      return;
    }

    final result = await _vision.analyze(
      bytes,
      config: aiConfig.config,
      context: _isScreenMode ? '폰 화면 사용 코칭' : '사용자 시야 코칭',
    );

    if (!mounted) return;

    final oracle = context.read<OracleProvider>();
    final tts = context.read<TtsService>();

    for (final obj in result.detectedObjects) {
      oracle.receiveCoachingTip(obj);
    }

    setState(() {
      _lastDescription = result.description;
      _lastCoachingTip = result.suggestions.isNotEmpty
          ? result.suggestions.join(' / ')
          : result.description;
      _isAnalyzing = false;
    });

    if (result.suggestions.isNotEmpty) {
      tts.whisper(result.suggestions.first);
    } else if (result.description.isNotEmpty) {
      tts.whisper(result.description);
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    setState(() {
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    });
    _camera?.dispose();
    _camera = CameraController(_cameras[_cameraIndex], ResolutionPreset.medium,
      enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    _camera!.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_camera == null || !_camera!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _camera!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _camera != null && _camera!.value.isInitialized;

    return Column(
      children: [
        // 상단 컨트롤 바
        _buildControlBar(),

        // 카메라 프리뷰 (화면의 60%)
        Expanded(
          flex: 6,
          child: isReady && !_isScreenMode
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_camera!),
                    // 활성화 오버레이
                    if (_isActive)
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _pulsingDot(),
                              const SizedBox(width: 4),
                              const Text('분석 중', style: TextStyle(
                                color: Color(0xFF0A0A0A), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    // 분석 중 로딩
                    if (_isAnalyzing)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4A574),
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                )
              : _isScreenMode
                  ? _buildScreenModePreview()
                  : _buildCameraLoading(),
        ),

        // 코칭 피드 (화면의 40%)
        Expanded(
          flex: 4,
          child: _buildCoachingPanel(),
        ),
      ],
    );
  }

  Widget _pulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withAlpha((value * 255).round()),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.remove_red_eye, color: Color(0xFFD4A574), size: 20),
          const SizedBox(width: 8),
          Text('👁️ 시선 — AI와 같은 화면 보기',
            style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          // 카메라/화면 전환 + 카메라 앞뒤 전환
          if (_cameras.length > 1)
            GestureDetector(
              onTap: _switchCamera,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flip_camera_android, color: Colors.white70, size: 18),
              ),
            ),
          const SizedBox(width: 6),
          // 📱 화면 / 📷 카메라 전환
          GestureDetector(
            onTap: _toggleMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isScreenMode
                    ? const Color(0xFF7CCE8C).withAlpha(25)
                    : const Color(0xFFD4A574).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isScreenMode
                    ? const Color(0xFF7CCE8C).withAlpha(100)
                    : Colors.transparent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_isScreenMode ? Icons.phone_android : Icons.camera_alt,
                    size: 14, color: _isScreenMode ? const Color(0xFF7CCE8C) : const Color(0xFFD4A574)),
                  const SizedBox(width: 4),
                  Text(_isScreenMode ? '화면' : '카메라',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: _isScreenMode ? const Color(0xFF7CCE8C) : const Color(0xFFD4A574))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 활성화 토글
          GestureDetector(
            onTap: _toggleActive,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48, height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _isActive ? const Color(0xFFD4A574) : Colors.grey.shade800,
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: _isActive ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 26, height: 26,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenModePreview() {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_android, size: 64, color: const Color(0xFF7CCE8C).withAlpha(100)),
            const SizedBox(height: 16),
            const Text('📱 폰 화면 공유 모드',
              style: TextStyle(color: Color(0xFF7CCE8C), fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_isActive ? 'MediaProjection으로 화면 분석 중...' : '토글을 켜면 화면 캡처 시작',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 4),
            Text('"OH MY META" — 폰 사용 패턴까지 AI가 인지합니다',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraLoading() {
    return Container(
      color: const Color(0xFF0D0D0D),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 48, color: Color(0xFF333333)),
            const SizedBox(height: 12),
            Text(_cameras.isEmpty ? '카메라를 찾을 수 없습니다' : '카메라 초기화 중...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachingPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(10))),
      ),
      child: Column(
        children: [
          // 코칭 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text('O.P', style: TextStyle(
                      color: Color(0xFF0A0A0A), fontWeight: FontWeight.w900, fontSize: 9)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(_isActive ? '실시간 시선 코칭' : '코칭 대기 중',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Icon(Icons.headphones, color: _isActive
                    ? const Color(0xFFD4A574).withAlpha(200)
                    : Colors.grey.shade700, size: 14),
              ],
            ),
          ),

          // 코칭 내용
          Expanded(
            child: _isActive
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (_lastDescription != null) ...[
                        _coachingBubble('🔍 본 것', _lastDescription!, const Color(0xFF8BB8EA)),
                        const SizedBox(height: 8),
                      ],
                      if (_lastCoachingTip != null) ...[
                        _coachingBubble('💡 제안', _lastCoachingTip!, const Color(0xFF7CCE8C)),
                      ],
                      if (_lastDescription == null && _lastCoachingTip == null)
                        _emptyCoaching(),
                    ],
                  )
                : _inactiveCoaching(),
          ),
        ],
      ),
    );
  }

  Widget _coachingBubble(String label, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _emptyCoaching() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 32, color: Colors.grey.shade700),
          const SizedBox(height: 8),
          Text('4초마다 화면 분석 중...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _inactiveCoaching() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye_outlined, size: 48, color: Colors.grey.shade800),
            const SizedBox(height: 12),
            const Text('카메라를 켜면 AI가 당신의 시선을 공유합니다',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF555555), fontSize: 14)),
            const SizedBox(height: 4),
            Text('화면을 보고 4초마다 귓속말 코칭',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopAnalysis();
    _screenCapture.dispose();
    _camera?.dispose();
    _vision.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
