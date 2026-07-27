# 🏛️ Architecture

> "The AI that knows you better than you know yourself."

## 1. Zero-Friction Onboarding

Button 1 → Instant activation. No setup required.

```
First Launch
  │
  ├─ [Start O.P] — one button
  │
  ├─ Mic permission (OS dialog)
  ├─ Notification permission
  │
  └─ "Hi friend!! I am your OraclePrompter."
      → Standby mode immediately
      → All 5 tabs accessible
      → On-device AI as default (no API key needed)
```

## 2. 5-Tab UX

```
Human cognition flow        →    O.P Tab Structure
─────────────────────────────────────────────
1. What's happening now?    →    🧠 Mind (real-time recognition)
2. Ask the AI               →    💬 Oracle (conversation)
3. AI sees through my eyes   →    👁️ Sight (Vision)
4. Review the past           →    📖 Journal (retrospect)
5. Adjust settings           →    🎛️ Control (environment)
```

- `IndexedStack` preserves tab state
- Each tab is independent `StatefulWidget`
- Minimum touch target 48x48dp
- High-contrast dark theme (WCAG AA)

## 3. Power Management

| Mode | Behavior | Battery | Trigger |
|------|----------|:---:|------|
| 🌙 **Saving** | STT only (5s buffer), graph 30s | 12h+ | Screen OFF + silence 5min |
| ⚡ **Normal** | STT real-time, graph 5s, Vision 15s | 6-8h | Screen ON or in call |
| 🚀 **Performance** | Full features, API real-time | 2-4h | Charging |

Options:
- Mic when screen OFF (toggle)
- Wi-Fi only API (toggle)
- Vision interval: 4–60s
- Graph interval: 2–30s
- Prefer on-device (toggle)

## 4. Phone-Centric Agent

O.P is an "Agent OS" — not just an app.

```
┌──────────────────────────────────────────┐
│              OraclePrompter               │
│  ┌────────────────────────────────────┐  │
│  │      Unified Markdown DB            │  │
│  │   (Single source of truth)          │  │
│  └────────────┬───────────────────────┘  │
│               │                           │
│  ┌────────────┼───────────────────────┐  │
│  │   Data Collection Layer            │  │
│  │  📞 Calls  📱 Notifications  📍 GPS│  │
│  │  📷 Camera 🎤 Mic  📅 Calendar     │  │
│  │  💬 SMS   🌐 Browser  📊 Health    │  │
│  └────────────┬───────────────────────┘  │
│               │                           │
│  ┌────────────┼───────────────────────┐  │
│  │   Processing Layer                 │  │
│  │  STT → LLM → MindGraph → Markdown  │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

## 5. Permanent Knowledge Base

```
vault/
├── index.md                    # Master index
├── sessions/                   # Raw session records
│   └── 2026-07-25_team-meeting.md
├── topics/                     # By subject
│   └── project-OP.md
├── entities/                   # By entity (person, place, concept)
│   └── person-kim.md
├── daily/                      # Daily digests
│   └── 2026-07-25.md
└── graph/                      # MindGraph JSON
```

### Session Markdown Example

```markdown
---
session_id: s_1721894400000
date: 2026-07-25T14:30:00+09:00
duration: 45m
location: Gangnam, Seoul
mood: productive
keywords: [AI, agent, mind-graph]
---

# Team Meeting

## Summary
Discussion on real-time AI coaching feasibility.

## Conversation
- 14:30 Kim: "Is this actually possible?"
- 14:32 Me: "Technically, all of this is already possible."

## Mind Graph
- AI-Agent → Feasibility → Tech-Stack

## Emotion Flow
Skeptical → Positive → Productive
```

## 6. App Data Integration Pipeline

```
Android Content Providers
    │
    ▼
DataCollector Service (background)
    ├─ CallLog → call-records.md
    ├─ SMS → messages.md
    ├─ Calendar → schedule.md
    ├─ Contacts → contacts.md
    ├─ Health Connect → health.md
    └─ UsageStats → app-usage.md
    │
    ▼
MarkdownExporter
    ├─ sessions/ (chronological)
    ├─ topics/ (by subject)
    └─ entities/ (by entity)
    │
    ▼
LLM Embedding → Vector DB → Semantic Search
```
