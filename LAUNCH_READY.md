# 🚀 GitHub Launch Plan

## Architecture Optimization

Current: 33 files across 6 layers with circular dependencies.  
Target: Domain-centric restructuring.

```
lib/
├── core/              ← Pure Dart, zero deps (tool, skill, memory, scheduler)
├── domain/
│   ├── conversation/  ← models + providers + services
│   ├── vision/        ← screens + services
│   ├── vault/         ← models + providers + screens + services
│   └── control/       ← screens + providers
└── shared/widgets/
```

## Critical Missions

| Priority | Mission | Status | Solution |
|:---:|------|--------|----------|
| P0 | Google Play approval | ❌ Accessibility Service | → MediaButtonReceiver |
| P0 | Call mic manipulation | ❌ Android security | → VoIP only, "Labs" feature |
| P1 | 24h battery | ⚠️ 6-8h theoretical | → PowerManager 3-tier, Moonshine STT |
| P1 | Constant mic/camera | ⚠️ Foreground Service done | → Permanent notification + indicator |
| P2 | Smart glasses camera | ⚠️ USB OTG only | → Wireless plugin separate |

## GitHub Feature List

### Core Features (in README)
- ✅ AI whisper coach
- ✅ Mind graph visualization
- ✅ Auto journal (markdown)
- ✅ AI engine choice (6 options)
- ✅ 4 conversation modes
- ✅ Stealth hotkeys (volume buttons)
- ✅ 3-tier power management

### Labs Features (opt-in)
- 👁️ Sight mode (camera Vision)
- 📱 Screen share (MediaProjection)
- 🛡️ Audio effects (VoIP only)
- 📊 App usage patterns

### Excluded from GitHub
- PSTN call audio manipulation (illegal)
- Accessibility Service (review impossible)
- "Deceive others" marketing language

## Privacy Modes

| Mode | Description | User |
|------|------------|------|
| 🟢 **Local Only** | On-device only, no internet, free | Default |
| 🟡 **Privacy First** | 24h auto-delete, AES-256 vault | Privacy focus |
| 🔴 **Enterprise** | Audit logs, SSO, SOC2/GDPR | Business/Gov |

## Roadmap

```
v1.0 Alpha (NOW)
  ✅ Architecture design complete
  ✅ 5-tab UI + onboarding
  ✅ AI engine switching
  ⬜ Remove Accessibility → MediaButtonReceiver
  ⬜ GitHub public launch

v1.1 Beta
  ⬜ llama.cpp actual integration
  ⬜ sherpa-onnx STT integration
  ⬜ Piper TTS integration
  ⬜ SQLite-vec semantic search

v1.2 Release
  ⬜ Google Play submission
  ⬜ Privacy Policy
  ⬜ Release signing
  ⬜ F-Droid listing

v2.0 Enterprise
  ⬜ Privacy modes complete
  ⬜ Smart glasses support
  ⬜ Paid API tier
```
