# 🚧 Hard Problems & O.P Solutions

> "Every always-on AI companion faces these. Here's how we solve each."

---

## 1. 🔋 Battery Life

**Problem**: 24/7 mic + periodic camera + LLM = 2-4 hours.

| Solution | Detail |
|----------|--------|
| 3-tier Power | Saving (STT only, 12h+) → Normal (6-8h) → Performance (charging) |
| DSP Wake Word | 0.5% CPU, 1%/h battery |
| Moonshine STT | 5x faster than Whisper, runs on CPU |
| INT4 Quantized LLM | Gemma 3 1B = 200MB RAM, 15 tok/s |
| Adaptive interval | Vision: 4s when active, 60s when idle |

---

## 2. 🔒 Privacy & Trust

**Problem**: "Is it always listening? Where does my data go?"

| Solution | Detail |
|----------|--------|
| On-device first | llama.cpp + sherpa-onnx run locally. No cloud needed. |
| Auto-delete originals | MediaClipper extracts clips → deletes raw files |
| Privacy mode | 24h auto-delete vault. AES-256 encryption. |
| Transparent notification | "O.P is listening" always visible. Stop button one tap away. |
| Card-granted permissions | Camera? "시선 모드를 켜볼까요?" [○][✕] — never forced |

---

## 3. 💀 Background Process Killing

**Problem**: Samsung Knox, Xiaomi MIUI, Huawei HMS kill apps aggressively.

| Solution | Detail |
|----------|--------|
| Foreground Service | Permanent notification. Android can't kill without user noticing. |
| Geek Mode guide | Per-manufacturer settings: Samsung Device Care, Xiaomi Autostart |
| Card-based education | "백그라운드 유지를 위해 설정이 필요해요. 도와드릴까요?" [○][✕] |
| Battery optimization exemption | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent |

---

## 4. 🎤 Microphone Contention

**Problem**: Can't use mic during phone calls or when another app has it.

| Solution | Detail |
|----------|--------|
| Call state detection | `TelecomManager` → pause O.P mic during calls |
| Audio focus handling | `AudioManager.OnAudioFocusChangeListener` → yield to phone calls |
| Fallback to text | If mic unavailable, card: "지금은 들을 수 없어요. 텍스트로 대화할까요?" |

---

## 5. 🐢 LLM Latency

**Problem**: On-device LLM = 2-5 tok/s. API = 200-500ms + network.

| Solution | Detail |
|----------|--------|
| Streaming response | Show tokens as they arrive (no waiting for full response) |
| Pre-compute predictions | MindGraph predicts next nodes before user asks |
| Tiered response | Simple answers → on-device (fast). Complex → API (smart) |
| Caching | Common queries cached. "What time is it?" → no LLM needed |

---

## 6. 💾 Storage Growth

**Problem**: Continuous recording fills storage.

| Solution | Detail |
|----------|--------|
| Clip-and-delete | MediaClipper: keep only important moments, delete raw |
| Hierarchical summarization | Raw → hourly → daily → weekly → monthly |
| 90-day archive policy | Old raw files compressed. Summaries kept forever. |
| 1 year = ~820MB | 3-tier storage (Markdown + SQLite + Vector) |

---

## 7. 🎯 STT Accuracy in Noise

**Problem**: Speech recognition fails in crowded cafes, streets.

| Solution | Detail |
|----------|--------|
| Multi-model fallback | sherpa-onnx (on-device) → Google STT (cloud) if accuracy low |
| Beamforming hint | Future: dual-mic noise reduction (hardware dependent) |
| Confidence threshold | Low confidence → card: "잘 못 들었어요. 다시 말씀해주실래요?" |
| Context correction | LLM post-processes STT output using conversation context |

---

## 8. 📦 Model Management

**Problem**: Users don't want to download 2GB GGUF files or manage versions.

| Solution | Detail |
|----------|--------|
| Card-guided download | "AI 모델을 다운로드할까요? 2.4GB예요." [○][✕] |
| Wi-Fi only | Auto-detect. Don't download on cellular. |
| Background download | DownloadManager API. User can keep using app. |
| Auto-update | Check HuggingFace for newer model versions. Card: "새 모델 나왔어요." |

---

## 9. 🔗 Cross-App Data Access

**Problem**: Call logs, SMS, calendar require separate permissions. Users forget to grant.

| Solution | Detail |
|----------|--------|
| Card-granted permissions | "통화 기록을 읽어도 될까요? 일정 관리에 도움이 돼요." [○][✕] |
| Progressive disclosure | Don't ask all at once. Ask when contextually relevant. |
| Clear benefit statement | Every permission card explains WHY: "약속을 기억해드릴게요" |

---

## 10. 🏢 Platform Risk

**Problem**: Google/Apple could block always-on mic apps at OS level.

| Solution | Detail |
|----------|--------|
| F-Droid distribution | Independent app store. No Google dependency. |
| HarmonyOS compatibility | Already documented. Huawei AppGallery route. |
| Direct APK download | GitHub Releases. No store needed. |
| Open source | If blocked, community forks and continues. |

---

## 11. 💰 Monetization Without Creepiness

**Problem**: How to make money without selling user data?

| Solution | Detail |
|----------|--------|
| Freemium model | Core features free (on-device). Premium: cloud API, advanced Vision. |
| Bring-your-own-key | User provides own OpenAI/Claude API key. O.P never sees it. |
| On-device forever free | llama.cpp + sherpa-onnx + Piper TTS = $0 cost. |
| Enterprise tier | SSO, audit logs, admin console → paid. |

---

## Summary

| # | Hard Problem | O.P's Solution |
|---|-------------|---------------|
| 1 | Battery | 3-tier power + DSP wake + INT4 quantization |
| 2 | Privacy | On-device first + auto-delete + transparent notification |
| 3 | Process killing | Foreground Service + per-manufacturer Geek guides |
| 4 | Mic contention | Audio focus + call detection + text fallback |
| 5 | LLM latency | Streaming + pre-compute + tiered response |
| 6 | Storage | Clip-and-delete + hierarchical summarization |
| 7 | Noisy STT | Multi-model fallback + context correction |
| 8 | Model management | Card-guided + background download + auto-update |
| 9 | Data access | Card-granted + progressive disclosure |
| 10 | Platform risk | F-Droid + HarmonyOS + direct APK |
| 11 | Monetization | Freemium + BYOK + on-device forever free |
