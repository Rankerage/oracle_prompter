# OraclePrompter Alpha

> **"Hi friend!! I am your OraclePrompter. I am always with you."**
>
> AI 귓속말 대화 코치 — 당신의 모든 대화를 더 똑똑하게.  
> 카메라만 열면 코칭이 시작됩니다. 화면 볼 필요 없이, 음성만으로 모든 기능을 제어하세요.

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-brightgreen" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="MIT">
  <img src="https://img.shields.io/badge/Status-Alpha-orange" alt="Alpha">
  <img src="https://img.shields.io/badge/Flutter-3.44-blue" alt="Flutter">
  <img src="https://img.shields.io/badge/Inspired-Hermes_Agent-purple" alt="Hermes">
</p>

---

## 🎯 왜 OraclePrompter인가

| 기존 AI 어시스턴트 | OraclePrompter |
|-------------------|---------------|
| 말 걸어야 대답함 | 항상 켜져 있음. 묻지 않아도 귓속말 |
| 스피커로 떠듬 | 이어폰 귓속말 (상대방에게 안 들림) |
| 텍스트 채팅 | 마이크+카메라로 당신의 상황을 직접 인식 |
| 세션 리셋 | 모든 대화가 마인드그래프 + 마크다운으로 영구 보존 |
| AI 하나 고정 | 온디바이스 / OpenAI / Claude / DeepSeek / Gemini 자유 선택 |
| 화면 봐야 함 | Voice-First. "O.P" 한 마디로 모든 제어 |

---

## 🚀 30초 시작

```bash
# 1. APK 다운로드
#    → Releases 페이지에서 app-debug.apk

# 2. 설치 + 권한 허용
#    → 마이크만 필수, 나머지는 선택

# 3. "O.P" 라고 말하기
#    → 즉시 코칭 시작

# 끝.
```

**최소 사양**: Android 10+, RAM 4GB+, 64-bit CPU  
**권장 사양**: Android 13+, RAM 8GB+, Bluetooth 5.0

---

## 🧠 핵심 기능

### 🎧 AI 귓속말 코치
```
당신의 대화 중에 AI가 실시간으로 귓속말 조언.
단어가 안 떠오를 때, 논리가 막힐 때, 상대가 TMI 폭격할 때.
"지금 타이밍에 침묵 3초 유지하세요."
```

### 👁️ 시선 모드
```
카메라만 켜면 AI가 당신과 같은 화면을 봅니다.
"설정 → 연결 → 블루투스로 이동하세요."
폰 화면 공유(MediaProjection)도 지원.
```

### 🧠 실시간 마인드그래프
```
대화 내용이 노드+엣지 그래프로 실시간 시각화.
예측 노드: 대화가 어디로 흐를지 미리 표시.
```

### 📖 자동 일기장
```
모든 대화가 마크다운으로 자동 저장.
위치, 감정, 참여자, 키워드가 메타데이터로 함께 기록.
```

### 🛡️ 방어·설득·상쾌·통역 4모드
```
🎭 방어 — 상대가 스스로 전화를 끊게
🧠 설득 — 상대를 내 편으로
🌿 상쾌 — 대화 후 기분 좋게 마무리
🌐 통역 — 실시간 번역
```

### 🔌 AI 엔진 자유 선택
```
📱 온디바이스 (llama.cpp, Gemma 3) — 무료, 오프라인
🤖 OpenAI (GPT-4o) — 최고 성능
🧠 Anthropic (Claude) — 긴 맥락
🔮 DeepSeek — 가성비
🌐 Gemini — Google 생태계
⚙️ 커스텀 (Ollama, vLLM) — 내 서버
```

---

## 🏗️ 아키텍처

OraclePrompter는 [Hermes Agent](https://github.com/NousResearch/hermes-agent)의 아키텍처를 모바일로 이식했습니다.

```
Hermes DNA —————————————→ O.P Alpha
──────────────────────────────────
🧰 Tools              → 마이크, 카메라, 화면캡처, 위치, 통화록, 문자, 캘린더
📦 Skills             → 방어/설득/상쾌/통역 모드 (마크다운 워크플로우)
🧠 Memory             → 마인드그래프 + Vault (3중 저장: Markdown+SQLite+Vector)
🔌 Providers          → 온디바이스 / OpenAI / Claude / DeepSeek / Gemini / Custom
👤 Profiles           → 세션별 맥락 분리
⏰ Cron               → 일간 다이제스트, 앱 사용 리포트
🔍 Session Search     → Vault FTS5 + 벡터 의미 검색
```

```
lib/
├── core/              ← Hermes DNA (tool, skill, memory, scheduler)
├── domain/            ← conversation, vision, vault, control
├── services/          ← AI, STT, TTS, Vision, Markdown
└── screens/           ← 5탭 UI + 온보딩
```

---

## 🎤 Voice-First 설계

```
"O.P" → (비프) → "방어 모드" → "작동합니다" 🎧
  ↑                              ↑
wake word (DSP, 항시)      귓속말 피드백 (0.5초)

모든 기능을 음성만으로. 화면 볼 필요 없음.
스마트 안경 전환 시 그대로 사용 가능.
```

---

## 📦 설치

### APK 다운로드
[Releases](https://github.com/mathe/oracle_prompter/releases) → `app-debug.apk`

### 직접 빌드
```bash
git clone https://github.com/mathe/oracle_prompter.git
cd oracle_prompter
flutter pub get
flutter build apk --debug
```

---

## 🤝 기여하기

OraclePrompter는 **여러분의 도움이 절실합니다.**

### 🔥 가장 시급한 HELP WANTED

| 우선순위 | 태스크 | 난이도 |
|:---:|------|:---:|
| 🔥🔥🔥 | **llama.cpp JNI 연동** → 온디바이스 LLM 실제 작동 | 고급 |
| 🔥🔥🔥 | **sherpa-onnx Flutter 연동** → 실시간 한국어 STT | 중급 |
| 🔥🔥 | **MediaProjection 구현** → 폰 화면 캡처 | 중급 |
| 🔥🔥 | **MarkdownExporter 실제 저장** → Vault 작동 | 초급 |
| 🔥 | **Wake word "O.P"** → VoiceInteractionService | 고급 |
| 🔥 | **SQLite-vec 연동** → 의미 검색 | 중급 |

### 기여 방법
1. [CONTRIBUTING.md](CONTRIBUTING.md) 읽기
2. Issue 탭에서 `help wanted` 찾기
3. Fork → Feature Branch → PR

---

## 📚 문서

| 문서 | 내용 |
|------|------|
| [HERMES_ALPHA.md](HERMES_ALPHA.md) | Hermes + Alpha 아키텍처 |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 전체 설계 + 전원관리 + 마크다운 지식베이스 |
| [VOICE_FIRST.md](VOICE_FIRST.md) | Voice-First + 자원 최소화 |
| [STORAGE_ARCHITECTURE.md](STORAGE_ARCHITECTURE.md) | 3중 저장 (Markdown + SQLite + Vector) |
| [SECURITY_AND_PERMISSIONS.md](SECURITY_AND_PERMISSIONS.md) | 권한 + Google Play 심사 |
| [SUBSYSTEMS.md](SUBSYSTEMS.md) | 오픈소스 서브시스템 선정 |
| [LAUNCH_READY.md](LAUNCH_READY.md) | GitHub 출시 계획 |

---

## 🙏 Inspired by

OraclePrompter's architecture is inspired by [Hermes Agent](https://github.com/NousResearch/hermes-agent) by [Nous Research](https://nousresearch.com) — the fully open-source AI agent that grows with you.

Both projects share the same DNA: Tools, Skills, Memory, Providers, and a commitment to open-source AI.

---

## 📄 License

MIT License — same as Hermes Agent.  
Copyright (c) 2026 OraclePrompter Contributors.

---

<p align="center">
  <b>OH MY META.</b><br>
  <i>"나보다 나를 더 잘 아는 AI"</i>
</p>
