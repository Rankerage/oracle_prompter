# 💾 3-Tier Storage Architecture

> "Markdown lasts forever. SQLite queries fast. Vector finds meaning."

## Why Markdown Alone Isn't Enough

| Problem | Markdown | Solution |
|---------|:---:|------|
| "Find Kim's idea from last week" | ❌ Full text only | Semantic search |
| "Happiest conversation ever" | ❌ No metadata | Emotion tags + query |
| Thousands of files | ❌ Slow (1s+) | Indexed search |
| "When did this concept first appear" | ❌ Must open files | Timeline query |
| Inject into LLM prompt | ✅ Native | — |
| Readable in 10 years | ✅ Plain text | — |
| Git version control | ✅ | — |

> **Markdown = permanent preservation. SQLite + Vector = fast search & analysis.**

## Three-Tier Structure

```
┌──────────────────────────────────────────────────┐
│                    OPVault                        │
│                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │  📝 Markdown │  │  🗄️ SQLite   │  │ 🧬 Vector │ │
│  │  Permanent   │  │  Fast query  │  │ Semantic  │ │
│  │             │  │              │  │ search    │ │
│  │ sessions/   │  │ sessions.db  │  │ *.vec     │ │
│  │ topics/     │  │ entities.db  │  │ (SQLite-  │ │
│  │ daily/      │  │ timeline.db  │  │  vec)     │ │
│  └─────────────┘  └──────────────┘  └──────────┘ │
└──────────────────────────────────────────────────┘
```

## Storage Estimation

| Period | Markdown | SQLite | Vector | Total |
|--------|:---:|:---:|:---:|:---:|
| 1 day | 2MB | 50KB | 300KB | 2.3MB |
| 1 week | 14MB | 350KB | 2MB | 16MB |
| 1 month | 60MB | 1.5MB | 8MB | 70MB |
| 1 year | 700MB | 18MB | 100MB | **820MB** |
| 10 years | 7GB | 180MB | 1GB | **8.2GB** |

> 32GB phone = 30 years. 128GB = a lifetime.

## Hierarchical Summarization

```
Level 0: Raw (markdown, permanent)
    │ hourly
Level 1: Hourly Summary (200 chars, SQLite)
    │ daily midnight
Level 2: Daily Digest (markdown + SQLite)
    │ weekly Monday
Level 3: Weekly Digest (markdown)
    │ monthly 1st
Level 4: Monthly Report (markdown)
```

## Old Data Policy

```
90+ days → Raw archived (compressed), summaries kept
365+ days → Weekly digests only, raw → cloud backup (optional)
```

## The Verdict

| Question | Answer |
|----------|--------|
| Is markdown the right direction? | ✅ Yes — **but needs SQLite + Vector as complements** |
| Keep markdown? | ✅ Absolutely. It's the permanent bone structure. |
| Add SQLite? | ✅ Fast queries, metadata, FTS5 |
| Add Vector DB? | ✅ Semantic search, context injection for LLM |

> **"Markdown is the skeleton. SQLite is the muscle. Vector is the nervous system."**
