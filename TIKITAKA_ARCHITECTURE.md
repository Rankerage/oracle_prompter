# 🧬 TikiTaka Architecture — Card-First, Plugin-Everything

## Core (불변)

```
TikiTaka Core
  ├── 🃏 Card System (ConversationCard, ChipCard, AskMeCard)
  ├── 🎯 Interest Engine (사용자 취향 학습)
  ├── 🗣️ NaturalTalk (자연스러운 말걸기)
  ├── 🧠 TikiTakaBrain (통합 지능)
  ├── 🔌 Plugin Registry
  ├── 📁 Markdown Vault
  ├── ⏱️ AI Timing Engine
  └── 🛡️ RateLimiter
```

## Plugins (선택)

```
Plugins/
  ├── 📚 Study Plugin
  │     ├── FSRS Bridge
  │     ├── LearningMode
  │     ├── SubjectPicker
  │     ├── ContentProfile (4 types)
  │     └── CardGenerator
  │
  ├── 🔧 VibeCoding Plugin
  │     ├── WSL Guide
  │     ├── Termux Guide
  │     ├── VPS Guide
  │     └── Hermes Guide
  │
  ├── 🎧 OraclePrompter Plugin
  │     ├── SelfVoiceCoach
  │     ├── MediaClipper
  │     ├── SmartClipper
  │     └── MindGraph
  │
  └── 🔗 Agent Gateway Plugin
        └── 외부 에이전트 연결
```

## 원칙

```
Core = 절대 변경 없음. 카드 인터페이스 그 자체.
Plugin = 원하는 대로 붙이고 뗀다.
TikiTaka 설치 = Core만. 2MB.
기능 추가 = 플러그인 로드.
```
