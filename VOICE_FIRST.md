# 🎤 Voice-First + Zero-Friction Design

> "Open the camera. Coaching begins. Voice controls everything."

## Minimum Entry Path

```
App launch → Camera preview (0.5s)
           → STT engine warmup (sherpa-onnx)
           → On-device LLM warmup (llama.cpp)

Say "O.P"   → Wake word detected → "Hi friend!"
           → Coaching session starts
           → Falls back to on-device if no API key
```

**1 touch + 1 word = coaching started.**

## Voice Command System

### Wake Word: "O.P"

```
Wake word (DSP, ultra-low-power)
    │
    ▼
Voice command (Intent Matching)
    │
    ├─ "defense mode"     → enable defense
    ├─ "persuasion mode"  → enable persuasion
    ├─ "what's happening" → TTS situational description
    ├─ "be quiet"         → pause coaching
    ├─ "say again"        → repeat last tip
    ├─ "save this"        → export session to markdown
    ├─ "sight mode"       → activate Vision AI
    ├─ "screen share"     → MediaProjection mode
    ├─ "Oracle"           → AI consulting mode
    ├─ "status"           → battery, session, mode report
    ├─ "settings"         → open settings
    └─ "end session"      → stop + daily digest
```

### Command Priority

| Priority | Command | Processing |
|:---:|------|-----------|
| P0 | Wake word "O.P" | DSP chip (0.5% CPU) |
| P1 | "defense/quiet" | Local intent matching (no network) |
| P2 | "what's happening" | STT → on-device LLM 1-token response |
| P3 | "Oracle" + question | API LLM (as needed) |

## Camera-Only Mode

```
CameraOnlyMode
    │
    ├─ Camera preview (480p, 15fps → ultra-low-power)
    ├─ Frame capture every 4s (JPEG quality=60%)
    ├─ Vision API or on-device Vision (Gemma 3)
    └─ TTS whisper output
```

### Resource Usage

| Mode | CPU | RAM | Network | Battery/h |
|------|:---:|:---:|:---:|:---:|
| CameraOnly | 8-12% | 300MB | 0 (on-device) | 10% |
| Full | 20-30% | 800MB | ~5MB/min (API) | 20-25% |

## Voice-Only UX (No Screen)

```
User: "O.P"  (wake word)
   ↓
System: (short beep — listening)
   ↓
User: "defense mode"
   ↓
System: (whisper) "Defense mode active. Volume down twice for noise."
```

## Resource Minimization

```
Layer 4: API (on-demand only)
  GPT-4o / Claude → deep questions
  Frequency: 0-1 calls/minute

Layer 3: On-Device LLM (continuous)
  Gemma 3 1B (INT4) → basic responses
  RAM: 200MB, 15 tok/s

Layer 2: STT + Vision (periodic)
  Moonshine (Whisper 5x faster)
  Vision: 480p, 4s interval

Layer 1: Wake Word (always)
  DSP chip → 0.5% CPU
  Battery: 1%/h
```

## Memory Budget (4GB device)

| Component | RAM | Notes |
|-----------|:---:|-------|
| OS + Flutter | 1.2GB | Fixed |
| Gemma 3 1B (INT4) | 200MB | On-device LLM |
| Moonshine STT | 80MB | Whisper replacement |
| MindGraph (100 nodes) | 40MB | Capped |
| Vault (SSD) | 0 (disk) | Markdown |
| Camera buffer | 50MB | 480p |
| Headroom | 2.4GB | ✅ |

## Smart Glasses Transition

```
Current (Phone)              →    Future (Glasses)
──────────────────────────────────────────────
Camera: CameraController     →    Glasses SDK (same interface)
Mic: AudioRecord             →    Glasses mic array
Speaker: AudioTrack (earbuds) →   Bone conduction
Wake: DSP "O.P"              →    Same (DSP on glasses)
Screen: Flutter UI           →    HUD overlay (reduced UI)
Battery: 4000mAh             →    200mAh (minimize!)
```

Glasses keep only Wake + STT + TTS. Rest processed on phone, streamed to glasses.
