/// OraclePrompter의 대화 모드
enum OracleMode {
  /// 🛡️ 방어 모드 - 다언증 회피, 통화 탈출
  defense('🛡️ 방어', '상대방이 스스로 전화를 끊게 만듭니다', 'defense'),

  /// 🧠 설득 모드 - 협상, 토론, 면접
  persuasion('🧠 설득', '상대를 내 편으로 만듭니다', 'persuasion'),

  /// 🌿 상쾌 모드 - 대화 후 좋은 기분을 남김
  refresh('🌿 상쾌', '대화 상대에게 좋은 인상을 남깁니다', 'refresh'),

  /// 🌐 통역 모드 - 실시간 번역
  translate('🌐 통역', '실시간으로 통역해 드립니다', 'translate');

  final String label;
  final String description;
  final String key;

  const OracleMode(this.label, this.description, this.key);
}

/// 오디오 이펙트 타입
enum AudioEffect {
  /// 다운샘플링 - 8kHz 로봇 목소리
  downsampling('8kHz 다운샘플링', '로봇처럼 뚝뚝 끊기는 음질'),

  /// 하울링 & 에코
  howlingEcho('하울링 & 에코', '자기 목소리가 울려서 말하기 어려움'),

  /// 화이트 노이즈
  whiteNoise('화이트 노이즈', '치지직- 잡음과 함께 통화'),

  /// 풍절음
  windNoise('풍절음', '바람 부는 야외처럼'),

  /// 마찰음
  frictionNoise('마찰음', '주머니 속 마이크 마찰'),

  /// DAF 역공
  dafReverse('DAF 역공', '0.2초 지연 피드백으로 말문 막힘'),

  /// 초저주파
  infrasound('초저주파', '생리적 불쾌감 유발'),

  /// 바이노럴 알파파
  binauralAlpha('알파파 유도', '상대를 편안하게'),

  /// 528Hz 솔페지오
  solfeggio528('528Hz 공명', '치유와 신뢰의 주파수');

  final String label;
  final String description;

  const AudioEffect(this.label, this.description);
}

/// 프리셋 - 즐겨찾는 이펙트 조합
class Preset {
  final String name;
  final OracleMode mode;
  final List<AudioEffect> effects;
  final String? customPrompt;
  final bool isFavorite;

  const Preset({
    required this.name,
    required this.mode,
    required this.effects,
    this.customPrompt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'mode': mode.key,
        'effects': effects.map((e) => e.name).toList(),
        'customPrompt': customPrompt,
        'isFavorite': isFavorite,
      };
}
