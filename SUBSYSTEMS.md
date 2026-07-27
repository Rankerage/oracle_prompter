# 📦 Open Source Subsystems

## Selection Criteria

- **Stars**: Community validation
- **License**: Permissive (MIT, Apache 2.0, LGPL)
- **Android Compatibility**: Runs on mobile
- **Flutter Integration**: Existing plugin or FFI-friendly

---

## 🧠 On-Device LLM Inference

| Engine | Stars | License | Best For |
|--------|:---:|---------|----------|
| **llama.cpp** | 71,000+ | MIT | GGUF models, maximum flexibility, low RAM |
| **MediaPipe LLM** | 28,000+ | Apache 2.0 | Easiest Android integration, Gemma official |
| MLC LLM | 19,000+ | Apache 2.0 | GPU acceleration, model variety |

> **Choice**: llama.cpp (flexibility) + MediaPipe (Gemma-specific)

## 🎤 Real-Time STT

| Engine | Stars | License | Best For |
|--------|:---:|---------|----------|
| **sherpa-onnx** | 3,500+ | Apache 2.0 | Real-time Korean STT, Flutter plugin, SenseVoice |
| whisper.cpp | 38,000+ | MIT | Best accuracy, Whisper Large V3 Turbo |
| Vosk | 4,000+ | Apache 2.0 | Lightweight, real-time |

> **Choice**: sherpa-onnx (real-time Korean + Flutter plugin)

### Korean Models
- `sherpa-onnx-sense-voice-zh-en-ja-ko-yue` — multilingual including Korean
- `sherpa-onnx-moonshine-tiny-ko` — ultra-light Korean

## 🗣️ Text-to-Speech

| Engine | Stars | License | Best For |
|--------|:---:|---------|----------|
| **Piper TTS** | 11,300+ | MIT | Raspberry Pi-level lightweight, 100+ voices |
| **SherpaTTS** | — | GPL-3.0 | F-Droid Android engine, Piper + Coqui voices |
| NekoSpeak | new | Apache 2.0 | Kokoro model, natural voice |
| Coqui TTS | 36,000+ | CPL | Best quality (discontinued) |

> **Choice**: SherpaTTS (system integration) + Piper (lightweight)

## 🎵 Audio DSP

| Library | Stars | License | Role |
|---------|:---:|---------|------|
| **Google Oboe** | 5,400+ | Apache 2.0 | Low-latency Android audio I/O |
| **SoundTouch** | — | LGPL | Pitch/tempo/rate manipulation |
| Rubber Band | — | GPL/Commercial | Industry standard pitch shift |

> **Choice**: Oboe (audio I/O) + SoundTouch (effects)

## 📊 Graph Layout

| Library | License | Role |
|---------|---------|------|
| **D3-force (algorithm)** | BSD-3 | Force-directed layout |
| **ForceSimulation** (custom) | MIT | Pure Dart implementation of D3-force |

> **Choice**: Custom ForceSimulation (zero dependencies)

---

## Integration Architecture

```
Mic → [sherpa-onnx] → text → [Piper TTS] → earbud output
            │                    │
            ▼                    ▼
     [llama.cpp] ←→ MindGraph ←→ Oracle Chat
            │
            ▼
     [Oboe] → Audio Effects (SoundTouch)
```
