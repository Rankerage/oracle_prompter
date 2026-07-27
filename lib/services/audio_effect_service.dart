import 'dart:math';
import 'package:just_audio/just_audio.dart';

/// 오디오 이펙트 엔진 - 노이즈, 하울링, 다운샘플링 등
///
/// 실제 통화 중 마이크 조작은 OS 제약이 있으므로,
/// 이 서비스는 자체 내부 오디오 재생(시뮬레이션)과
/// 향후 실제 DSP 파이프라인을 위한 인터페이스를 함께 제공합니다.
class AudioEffectService {
  final Map<String, AudioPlayer> _players = {};
  final Random _random = Random();

  AudioEffectService();

  // --- 노이즈 생성기 (순수 Dart) ---

  /// 화이트 노이즈 버퍼 생성
  List<int> generateWhiteNoise(int samples, double amplitude) {
    final buffer = List<int>.generate(samples * 2, (_) {
      final sample = (_random.nextDouble() * 2 - 1) * amplitude * 32767;
      return sample.round() & 0xFFFF;
    });
    return buffer;
  }

  /// 하울링 시뮬레이션 - 피드백 루프
  List<int> simulateHowling(int samples, double freq, double amplitude) {
    final buffer = <int>[];
    double phase = 0;
    for (int i = 0; i < samples; i++) {
      phase += 2 * pi * freq / 44100;
      if (phase > 2 * pi) phase -= 2 * pi;
      // 하울링은 점점 진폭이 커짐
      final env = (1.0 - exp(-i / 22050.0)) * amplitude;
      final sample = (sin(phase) * env * 32767).round();
      buffer.add(sample & 0xFFFF);
    }
    return buffer;
  }

  /// 로봇 목소리 시뮬레이션 (비트 크러셔)
  double bitCrush(double sample, int bits) {
    final quantize = (1 << bits).toDouble();
    return ((sample * quantize).round() / quantize).clamp(-1.0, 1.0);
  }

  /// DAF - 지연 청각 피드백
  List<double> applyDAF(List<double> samples, int delaySamples, double mix) {
    final output = List<double>.from(samples);
    for (int i = delaySamples; i < samples.length; i++) {
      output[i] = samples[i] + samples[i - delaySamples] * mix;
    }
    return output;
  }

  // --- 모드별 프로필 ---

  /// 방어 모드: 상대방이 답답해서 끊게 만드는 소리
  String describeDefenseEffect() =>
      '상대에게 치지직- 노이즈와 함께 목소리가 뭉개지게 들립니다. '
      '자연스럽게 통화가 짧아집니다.';

  /// 설득 모드: 신뢰감을 주는 주파수 특성
  String describePersuasionEffect() =>
      '당신의 목소리에 알파파 공명을 실어 상대에게 깊은 신뢰감을 줍니다. '
      '상대는 무의식적으로 당신의 말에 설득됩니다.';

  /// 상쾌 모드: 대화 후 기분 좋은 잔향
  String describeRefreshEffect() =>
      '528Hz 솔페지오 주파수로 대화가 기분 좋게 마무리됩니다. '
      '상대는 당신과의 대화를 긍정적으로 기억합니다.';

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
  }
}
