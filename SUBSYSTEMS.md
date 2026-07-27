# ██████╗  ██████╗     ███████╗██╗   ██╗██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
# ██╔═══██╗██╔═══██╗    ██╔════╝██║   ██║██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
# ██║   ██║██║   ██║    ███████╗██║   ██║██████╔╝███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
# ██║   ██║██║   ██║    ╚════██║██║   ██║██╔══██╗╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
# ╚██████╔╝╚██████╔╝    ███████║╚██████╔╝██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
#  ╚═════╝  ╚═════╝     ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝

# OraclePrompter — 오픈소스 서브시스템 매니페스트
# 각 분야 최고의 오픈소스를 선정하여 통합

subsystems:
  # ─── 온디바이스 LLM 추론 ───
  llm:
    - name: llama.cpp
      github: ggerganov/llama.cpp
      stars: "71,000+"
      license: MIT
      role: "GGUF 모델 온디바이스 추론 엔진"
      android: "JNI 바인딩 → flutter_llama 또는 직접 NDK 연동"
      pros:
        - "모든 GGUF 모델 지원 (Gemma, Llama, Phi, DeepSeek 등)"
        - "극도로 낮은 메모리 사용량 (4GB RAM에서도 실행)"
        - "커뮤니티 최대, 모델 생태계 최대"
        - "양자화 (Q4_K_M 등) 지원으로 모바일 최적화"
      cons:
        - "JNI/NDK 설정이 다소 복잡"
        - "GPU 가속은 수동 설정 필요"

    - name: MediaPipe LLM Inference API
      github: google-ai-edge/mediapipe
      stars: "28,000+"
      license: Apache 2.0
      role: "Google 공식 온디바이스 LLM API"
      android: "Gradle 의존성 추가 → 바로 사용 가능"
      pros:
        - "Android 네이티브 통합이 가장 쉬움"
        - "GPU 가속 내장"
        - "Gemma 3 모델 공식 지원"
      cons:
        - "지원 모델 제한적 (Gemma, Phi, Falcon)"
        - "GGUF 범용 모델은 미지원"

    # ★ 추천: llama.cpp (범용성) + MediaPipe (Gemma 전용)

  # ─── 실시간 음성인식 (STT) ───
  stt:
    - name: sherpa-onnx
      github: k2-fsa/sherpa-onnx
      stars: "3,500+"
      license: Apache 2.0
      role: "실시간 온디바이스 STT (Whisper + SenseVoice + Moonshine)"
      android: "Flutter 플러그인 존재 (sherpa_onnx)"
      pros:
        - "SenseVoice 모델: 한국어 포함 다국어 실시간 인식"
        - "Moonshine: 초경량 (Whisper 대비 5배 빠름)"
        - "VAD (Voice Activity Detection) 내장"
        - "Flutter/Dart 패키지 존재"
      cons:
        - "Whisper.cpp 대비 인지도 낮음"
      models:
        - "sherpa-onnx-sense-voice-zh-en-ja-ko-yue (한국어 지원 ★)"
        - "sherpa-onnx-moonshine-tiny-ko (한국어 경량)"

    - name: whisper.cpp
      github: ggerganov/whisper.cpp
      stars: "38,000+"
      license: MIT
      role: "OpenAI Whisper의 C++ 포트"
      pros:
        - "Whisper Large V3 Turbo 지원 (최고 정확도)"
        - "커뮤니티 최대"
      cons:
        - "실시간 처리에 무거움"
        - "한국어 WER이 다소 높음"

    # ★ 추천: sherpa-onnx (실시간+한국어+Flutter 패키지)

  # ─── 음성합성 (TTS) ───
  tts:
    - name: Piper TTS
      github: rhasspy/piper
      stars: "11,300+"
      license: MIT (forked)
      role: "초경량 온디바이스 TTS"
      android: "SherpaTTS (F-Droid) 엔진으로 사용 가능"
      pros:
        - "Raspberry Pi에서도 실시간 동작 (초경량)"
        - "100+ 음성, 30+ 언어"
        - "한국어 음성 다수"
      cons:
        - "AI 보이스 품질은 중간 수준"

    - name: SherpaTTS
      f-droid: org.woheller69.ttsengine
      license: GPL-3.0
      role: "Piper + Coqui 기반 Android TTS 엔진"
      android: "F-Droid에서 APK 설치 → 시스템 TTS로 등록"
      pros:
        - "Piper와 Coqui 음성을 Android 시스템 TTS로 통합"
        - "완전 오프라인"
        - "한국어 다수 음성"

    - name: NekoSpeak
      github: siva-sub/NekoSpeak
      license: Apache 2.0
      role: "ONNX Runtime 기반 Android 온디바이스 TTS"
      pros:
        - "Kokoro 모델 사용 (자연스러운 음성)"
        - "100% 오프라인"
        - "저지연"

    # ★ 추천: SherpaTTS (시스템 통합) + Piper (경량)

  # ─── 오디오 DSP ───
  audio_dsp:
    - name: Google Oboe
      github: google/oboe
      stars: "5,400+"
      license: Apache 2.0
      role: "Android 저지연 오디오 I/O"
      pros:
        - "AAudio + OpenSL ES 자동 선택"
        - "최저 레이턴시 (10ms 이하)"
        - "Google 공식, Android 표준"

    - name: Rubber Band
      github: breakfastquay/rubberband
      license: GPL/Commercial
      role: "피치 시프트 / 타임 스트레치"
      pros:
        - "업계 표준 피치 변환 라이브러리"
        - "실시간 처리 가능"
      cons:
        - "상업용 라이선스 필요 가능성"

    - name: SoundTouch
      github: soundtouch/soundtouch
      license: LGPL
      role: "오디오 피치/템포/레이트 조절"
      pros:
        - "LGPL 라이선스 (상업용 무료)"
        - "실시간 처리"

    # ★ 추천: Oboe (오디오 I/O) + SoundTouch (이펙트)

  # ─── 그래프 레이아웃 ───
  graph_layout:
    - name: d3-force-flutter
      github: MathGaps/d3-force-flutter
      license: BSD-3
      role: "D3.js force-directed layout의 Dart 구현"
      pros:
        - "D3-force 알고리즘 그대로 Flutter에 적용"
        - "노드/엣지 물리 시뮬레이션 (중력, 척력, 링크 힘)"
      cons:
        - "개발 초기 단계 (스타 적음)"

    - name: flutter_force_directed_graph
      pub: flutter_force_directed_graph
      role: "Flutter 전용 force-directed 그래프 위젯"
      pros:
        - "바로 사용 가능한 위젯"
        - "커스터마이징 가능"

    # ★ 추천: d3-force-flutter (알고리즘) → MindGraphPainter에 통합
