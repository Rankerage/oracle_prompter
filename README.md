# 톡톡 (TokTok) — NoStressAI

> **"AI가 먼저 톡톡."**
>
> No commands. No syntax. No stress.  
> AI talks first. You just tap ○ or ✕.  
> The world's first **NoStressAI** companion.

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-brightgreen" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="MIT">
  <img src="https://img.shields.io/badge/Status-Alpha-orange" alt="Alpha">
  <img src="https://img.shields.io/badge/For-Everyone-9cf" alt="For Everyone">
</p>

---

## 🎯 What OraclePrompter Is

| ✅ Does | ❌ Does NOT |
|--------|-----------|
| 🎧 Whisper-coach your conversations | Write code or build apps |
| 🧠 Build your personal mind graph | Run terminal commands |
| 📖 Auto-journal your life | Edit files or manage servers |
| 🃏 Learn your preferences via cards | Replace your IDE |
| ⏰ Remind you of what matters | Debug your program |
| 🔗 **Delegate to other agents** when needed | Act as a developer tool |

> **O.P is not a coding agent. It's your companion.**  
> Need code written? O.P can connect you to an agent that does.  
> But O.P itself stays focused on YOU — your conversations, your learning, your life.

---

## 🎯 Why OraclePrompter Exists

> **99% of AI tokens are consumed by 1% of people.**  
> Developers build for developers. Everyone else is left behind.

O.P flips this. **Zero learning curve.** No commands. No syntax. No terminal.

Just cards. Tap "Yes" or "No". That's it.

| Traditional AI | OraclePrompter |
|---------------|---------------|
| You must learn its language | It learns your preferences |
| Type commands, remember syntax | Tap cards, speak naturally |
| Built for developers | **Built for everyone** |
| Stares at you from a screen | Whispers in your ear |
| You configure everything upfront | **Perfect in one week** — it learns you |

> **"설정은 없습니다. 일주일만 같이 지내면 완벽해집니다."**

---

## 🚀 Start in 30 Seconds

```bash
# 1. Download APK from Releases
# 2. Install. Grant microphone permission.
# 3. Say "O.P" — coaching begins.

# Works on ANY Android 10+ phone, even 2GB RAM.
# Uses free API by default. On-device AI optional.
```

**Minimum**: Android 10+, 2GB RAM (API mode)  
**For on-device**: 4GB RAM, 64-bit CPU  
**Recommended**: Android 13+, 8GB RAM, Bluetooth 5.0

---

## 🧠 Core Features

### 🎧 AI Whisper Coach
```
Real-time earpiece guidance during any conversation.
Can't find the right word? Logic stuck? Someone TMI-bombing you?
"Stay silent for 3 seconds right now."
```

### 👁️ Sight Mode
```
Open the camera. AI sees what you see.
"Go to Settings → Connections → Bluetooth."
Phone screen sharing via MediaProjection also supported.
```

### 🧠 Real-Time Mind Graph
```
Conversation visualized as live node+edge graph.
Predicted nodes: see where the conversation is heading before it goes there.
```

### 📖 Auto Journal
```
Every conversation saved as markdown automatically.
Location, mood, participants, keywords — all stored as metadata.
```

### 🛡️ Four Conversation Modes
```
🎭 Defense — they'll want to hang up first
🧠 Persuasion — bring them to your side
🌿 Refresh — leave them feeling great
🌐 Translate — real-time interpretation
```

### 🔌 Choose Your AI Engine
```
📱 On-Device (llama.cpp, Gemma 3) — free, offline
🤖 OpenAI (GPT-4o) — best quality
🧠 Anthropic (Claude) — long context
🔮 DeepSeek — best value
🌐 Gemini — Google ecosystem
⚙️ Custom (Ollama, vLLM) — your own server
```

---

## 🏗️ Architecture

OraclePrompter ports [Hermes Agent](https://github.com/NousResearch/hermes-agent)'s architecture to mobile.

```
Hermes DNA —————————————→ O.P Alpha
──────────────────────────────────
🧰 Tools              → Mic, Camera, Screen Capture, Location, Call Log, SMS, Calendar
📦 Skills             → Defense/Persuasion/Refresh/Translate (markdown workflows)
🧠 Memory             → MindGraph + Vault (3-tier: Markdown+SQLite+Vector)
🔌 Providers          → On-device / OpenAI / Claude / DeepSeek / Gemini / Custom
👤 Profiles           → Per-session context isolation
⏰ Cron               → Daily digest, app usage reports
🔍 Session Search     → Vault FTS5 + vector semantic search
```

```
lib/
├── core/              ← Hermes DNA (tool, skill, memory, scheduler)
├── models/            ← Data models
├── providers/         ← State management (Provider pattern)
├── screens/           ← 5-tab UI + onboarding
├── services/          ← AI, STT, TTS, Vision, Markdown
└── widgets/           ← Reusable widgets
```

---

## 🎤 Voice-First Design

```
"O.P" → (beep) → "defense mode" → "activated" 🎧
  ↑                              ↑
wake word (DSP, always-on)   earpiece response (0.5s)

Every feature controllable by voice. No screen needed.
Ready for smart glasses transition — same interface, different hardware.
```

---

## 📦 Install

### Download APK
[Releases](https://github.com/Rankerage/oracle_prompter/releases) → `app-debug.apk`

### Build from Source
```bash
git clone https://github.com/Rankerage/oracle_prompter.git
cd oracle_prompter
flutter pub get
flutter build apk --debug
```

---

## 🤝 Contributing

OraclePrompter **needs your help.** Most services are stubs waiting for implementation.

### 🔥 Most Urgent HELP WANTED

| Priority | Task | Difficulty |
|:---:|------|:---:|
| 🔥🔥🔥 | **llama.cpp JNI binding** — make on-device LLM actually work | Advanced |
| 🔥🔥🔥 | **sherpa-onnx Flutter integration** — real-time Korean STT | Intermediate |
| 🔥🔥 | **MediaProjection implementation** — phone screen capture | Intermediate |
| 🔥🔥 | **MarkdownExporter actual file I/O** — make Vault work | Beginner |
| 🔥 | **Wake word "O.P"** — VoiceInteractionService | Advanced |
| 🔥 | **SQLite-vec integration** — semantic search | Intermediate |

### How to Contribute
1. Read [CONTRIBUTING.md](CONTRIBUTING.md)
2. Find a `help wanted` issue
3. Fork → Feature Branch → PR

---

## 📚 Documentation

| Doc | Contents |
|-----|----------|
| [HERMES_ALPHA.md](HERMES_ALPHA.md) | Hermes + Alpha architecture |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Full system design + power management + markdown knowledge base |
| [VOICE_FIRST.md](VOICE_FIRST.md) | Voice-First + resource minimization |
| [STORAGE_ARCHITECTURE.md](STORAGE_ARCHITECTURE.md) | 3-tier storage (Markdown + SQLite + Vector) |
| [SECURITY_AND_PERMISSIONS.md](SECURITY_AND_PERMISSIONS.md) | Permission matrix + Google Play review analysis |
| [SUBSYSTEMS.md](SUBSYSTEMS.md) | Open source subsystem selection |
| [LAUNCH_READY.md](LAUNCH_READY.md) | GitHub launch plan |

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
  <i>"The AI that knows you better than you know yourself."</i>
</p>
