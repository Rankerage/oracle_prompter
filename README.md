# OraclePrompter — TikiTaka Codebase + Plugins

> 🟡 **이 저장소는 TikiTaka의 전체 코드베이스입니다.**
>
> 👉 실제 앱 홍보는 **[Rankerage/tikitaka](https://github.com/Rankerage/tikitaka)** & **[tikitaka.study](https://tikitaka.study)** 에서 확인하세요.

---

## 📂 이 저장소에는

```
lib/
├── core/          # TikiTaka 핵심 (카드·뇌·Vault)
├── widgets/       # ConversationCard, ChipCard, SubjectPicker
├── services/      # FSRSBridge, NaturalTalk, NextCardEngine
├── plugins/
│   ├── study/     # 📚 Study Plugin
│   ├── vibe_coding_plugin.dart  # 🔧 VibeCoding
│   ├── phone_helper.dart        # 📱 PhoneHelper
│   └── oracle_prompter/         # 🎧 OraclePrompter Plugin (미래)
└── models/        # ContentProfile, AIProvider
```

---

## 🔗 관계

```
TikiTaka (앱) ──── 이 코드로 빌드됨
  ├── 코어: 카드 인터페이스 (불변)
  └── 플러그인: Study, VibeCoding, PhoneHelper, OraclePrompter...
```

| 저장소 | 역할 |
|--------|------|
| 🔗 **[tikitaka](https://github.com/Rankerage/tikitaka)** | 랜딩 페이지 + 다운로드 |
| 📁 **oracle_prompter** (현재) | 코드 + 플러그인 개발 |

---

## 🚀 빌드

```bash
flutter build apk --debug
# → build/app/outputs/flutter-apk/app-debug.apk
```

---

## 📄 문서

- [CARD_PRINCIPLES.md](CARD_PRINCIPLES.md) — 카드 운용 원칙
- [TIKITAKA_ARCHITECTURE.md](TIKITAKA_ARCHITECTURE.md) — 플러그인 아키텍처
- [PLUGIN_ANALYSIS.md](PLUGIN_ANALYSIS.md) — 각 플러그인 분석
- [FUTURE_PLUGINS.md](FUTURE_PLUGINS.md) — 미래 플러그인 아이디어 30+
- [COMPETITIVE_EDGE.md](COMPETITIVE_EDGE.md) — 폰AI 대비 우위

---

## 📜 License

MIT. Inspired by [Hermes Agent](https://github.com/NousResearch/hermes-agent).
