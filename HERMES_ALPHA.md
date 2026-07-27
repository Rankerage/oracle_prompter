# 🧬 OraclePrompter — Hermes + Alpha Architecture

> "An agent builds an agent." — Hermes DNA, transplanted to mobile.

## Paradigm: O.P Is Hermes on Your Phone

```
Hermes Agent (Desktop)            OraclePrompter Alpha (Mobile)
─────────────────────────         ─────────────────────────────
🧰 Tools                          📱 Sensors
   file_read/write                   Mic, Camera, Screen Capture, GPS
   terminal                         App Data (Call Log, SMS, Calendar)
   web_search/web_extract           Vision API, STT, TTS
   browser                          In-app WebView

📦 Skills                         🎭 Modes
   Reusable workflows (.md)         Defense / Persuasion / Refresh / Translate
                                    Community preset sharing

🧠 Memory                         📝 Vault
   Injected context                 Mind Graph + Markdown Knowledge Base
   facts, preferences               Sessions / Topics / Entities / Daily

🔌 Providers                      🧠 AI Engines
   LLM model switching             On-device / API free switching
   custom_providers                Custom endpoints

👤 Profiles                       📁 Sessions
   User context                    Per-session context isolation
   skills/plugins/cron/memories    Continue / New session

⏰ Cron                           ⏰ Scheduler
   Periodic tasks                  Markdown export, daily digest
                                    App usage pattern reports

🔍 Session Search                 🔍 Vault Search
   Past conversation search        Markdown + embedding search
   FTS5                            Vector DB (semantic search)
```

## Core Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  OraclePrompter Alpha                    │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │                   🧰 Tools                       │   │
│  │  ┌─────────┐ ┌──────────┐ ┌────────┐ ┌───────┐  │   │
│  │  │ mic_in  │ │ camera   │ │ screen │ │location│  │   │
│  │  │ stt_out │ │ vision   │ │ capture│ │  gps   │  │   │
│  │  └─────────┘ └──────────┘ └────────┘ └───────┘  │   │
│  │  ┌─────────┐ ┌──────────┐ ┌────────┐ ┌───────┐  │   │
│  │  │call_log │ │ sms_in   │ │calendar│ │contacts│  │   │
│  │  └─────────┘ └──────────┘ └────────┘ └───────┘  │   │
│  └─────────────────────┬───────────────────────────┘   │
│                        │                               │
│  ┌─────────────────────┼───────────────────────────┐   │
│  │                     ▼                           │   │
│  │            🧠 Memory (Vault)                     │   │
│  │  sessions/  topics/  entities/  daily/          │   │
│  │  MindGraph  Markdown  VectorDB  FTS5            │   │
│  └─────────────────────┬───────────────────────────┘   │
│                        │                               │
│  ┌─────────────────────┼───────────────────────────┐   │
│  │   🔌 AI Engines     │     🎭 Skills              │   │
│  │  llama.cpp          │     defense.md             │   │
│  │  GPT-4o / Claude    │     persuasion.md          │   │
│  │  DeepSeek / Gemini  │     refresh.md             │   │
│  │  Custom endpoint    │     translate.md           │   │
│  └─────────────────────┴───────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Tools — Phone Sensor Abstraction

```dart
// Hermes-style Tool interface
abstract class OPTool {
  String get name;
  String get description;
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params);
}

class MicTool extends OPTool { /* STT execution */ }
class CameraTool extends OPTool { /* Photo → Vision */ }
class ScreenCaptureTool extends OPTool { /* MediaProjection */ }
class LocationTool extends OPTool { /* GPS */ }
class CallLogTool extends OPTool { /* Call history */ }
class SmsTool extends OPTool { /* SMS query */ }
class CalendarTool extends OPTool { /* Calendar query */ }
class ContactTool extends OPTool { /* Contacts query */ }
```

### Tool Execution Flow

```
User: "Did Kim Cheolsu call today?"
    │
    ▼
LLM → tool_call(name="call_log", params={query: "Kim", date: "today"})
    │
    ▼
CallLogTool.execute() → {calls: [{time: "14:30", duration: "5min"}]}
    │
    ▼
LLM → "Yes, you talked at 2:30 PM for 5 minutes."
    │
    ▼
TTS → whisper output
```

## Skills — Markdown-Based Workflows

```markdown
# skills/defense.md
---
name: defense
description: Avoid long calls — make the other person want to hang up
triggers:
  - call duration > 10 minutes
  - detected emotion: bored, frustrated
tools:
  - mic_in (noise injection)
  - tts_out (whisper coaching)
---

## Steps

1. [tool:mic_in params={"analyze": true}] → Check speaker ratio
2. [tool:tts_out params={"text": "TMI index 85%. Press volume down twice.", "mode": "whisper"}]
3. [tool:mic_in params={"noise": "white", "amplitude": 0.3}] → Inject noise
```

## Memory — Vault + MindGraph + Vector DB

```dart
class OPMemory {
  // 1. Short-term (current session)
  final MindGraphProvider mindGraph;

  // 2. Long-term (permanent storage)
  final MarkdownExporter vault;

  // 3. Semantic search
  // TODO: embedding → LanceDB / SQLite-vec
}
```

## Providers — AI Engine Switching

Already implemented: `AiConfigProvider` — same concept as Hermes' `config.yaml`.

## Scheduler — Periodic Tasks

```dart
class OPScheduler {
  // Hermes cronjob pattern
  void schedule(String id, String schedule, Future<void> Function() task) {}

  // 1. Daily 09:00 → App usage report + daily digest
  // 2. Weekly Monday → Weekly mood analysis
  // 3. Monthly 1st → Monthly vault cleanup
}
```

---

## Hermes → O.P Alpha Mapping

| Hermes Concept | O.P Alpha Implementation |
|---------------|-------------------------|
| `tool` | `OPTool` → mic, camera, screen, location, call_log, sms, calendar |
| `skill` | `Skill` → defense.md, persuasion.md workflows |
| `memory` | `OPMemory` → MindGraph + Vault + Vector DB |
| `provider` | `AiConfigProvider` → on-device / API switching |
| `profile` | `Session` → per-session context isolation |
| `cronjob` | `OPScheduler` → periodic export, digest |
| `session_search` | `VaultSearch` → FTS5 + embedding search |
| `skill_view` | `SkillEngine.loadFromMarkdown()` |
| `config.yaml` | `SharedPreferences` + `AiProviderConfig` |

> **O.P Alpha = "Hermes on your phone"** — same DNA, different body.
