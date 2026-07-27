# 🤝 Contributing to OraclePrompter

> **"An agent building an agent" — build it together.**

---

## Quick Start

```bash
# 1. Install Flutter (https://docs.flutter.dev/get-started/install)
# 2. Clone
git clone https://github.com/Rankerage/oracle_prompter.git
cd oracle_prompter
# 3. Get dependencies
flutter pub get
# 4. Check for errors
flutter analyze
# 5. Run (requires Android device or emulator)
flutter run
```

---

## Development Environment

| Component | Version |
|-----------|---------|
| Flutter | 3.44+ |
| Dart | 3.12+ |
| Android SDK | 35+ |
| Java | 17+ (Temurin recommended) |
| Gradle | 9.1.0 |

---

## Project Structure

```
lib/
├── core/              ← Hermes DNA. Pure Dart. Zero dependencies.
│   ├── tool.dart      ← OPTool abstract class
│   ├── skill.dart     ← Skill engine (markdown → workflow)
│   ├── memory.dart    ← Unified memory system
│   └── scheduler.dart ← Cron jobs
├── models/            ← Data models
├── providers/         ← State management (Provider pattern)
├── screens/           ← UI (5 tabs + onboarding)
├── services/          ← Implementations (AI, STT, TTS, Vision, Markdown)
└── widgets/           ← Reusable components
```

### Pick Your Domain

| Domain | Directory | Difficulty |
|--------|-----------|:---:|
| Conversation | `services/ai_service.dart` | Intermediate |
| Vision | `screens/eye_screen.dart` | Intermediate |
| Knowledge Base | `services/markdown_exporter.dart` | Beginner |
| Control Panel | `screens/control_screen.dart` | Beginner |
| On-Device LLM | `services/ai_service.dart` → JNI | Advanced |

---

## Code Style

```dart
// ✅ Good
/// Tool that converts microphone input to STT
class MicTool extends OPTool {
  @override String get name => 'mic_in';

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    // sherpa-onnx STT execution
  }
}

// ❌ Bad
class mic extends optool {
  String get n => 'm'; // meaningless abbreviation
}
```

- `flutter format .` required
- `flutter analyze` must return 0 errors
- `///` doc comments on classes and public methods
- Provider pattern: always call `notifyListeners()` on state changes

---

## PR Process

```
1. Open an Issue (bug report or feature proposal)
2. Fork → Feature Branch (feature/xxx or fix/xxx)
3. Code → flutter format → flutter analyze
4. Open PR using the template below
5. Review → Revise → Merge
```

### PR Template

```markdown
## Description
Brief description of changes.

## Related Issue
Closes #123

## Checklist
- [ ] flutter analyze passes
- [ ] flutter test passes
- [ ] Tested on Android device

## Screenshots
(if UI changes)
```

---

## 🔥 HELP WANTED

### Critical (app won't work without these)

| # | Task | Description | Stack |
|---|------|-------------|-------|
| 1 | **llama.cpp JNI binding** | Make OnDeviceAiService actually run | C++, JNI, Android NDK |
| 2 | **sherpa-onnx STT** | Real-time Korean speech recognition | C++, ONNX, Flutter FFI |
| 3 | **MediaProjection** | Phone screen capture implementation | Android SDK, MethodChannel |

### High Priority

| # | Task | Description | Stack |
|---|------|-------------|-------|
| 4 | **MarkdownExporter file I/O** | Write Vault files to disk | Dart, File I/O |
| 5 | **SQLite schema** | Metadata storage | SQLite, sqflite |
| 6 | **ForceSimulation animation** | Smooth mind graph movement | Dart, CustomPainter |

### Nice to Have

| # | Task | Description | Stack |
|---|------|-------------|-------|
| 7 | **Wake word "O.P"** | VoiceInteractionService | Android, DSP |
| 8 | **SQLite-vec** | Semantic search | C++, SQLite extension |
| 9 | **Piper TTS integration** | On-device Korean TTS | C++, Flutter FFI |

---

## Code of Conduct

### We:
- ✅ **Welcome beginners.** No such thing as a "dumb question."
- ✅ **Accept Korean and English.** Issues and PRs in any language.
- ✅ **Celebrate failure.** Break things — we'll fix them together.
- ✅ **Respect ideas.** "What about this?" is always welcome.

### We don't:
- ❌ Tolerate aggressive or disrespectful behavior
- ❌ Give dismissive "that won't work" style feedback
- ❌ Attack people in code reviews

---

## Contact

- Issues: [Bug reports / Feature requests](https://github.com/Rankerage/oracle_prompter/issues)
- Discussions: [Ideas & brainstorming](https://github.com/Rankerage/oracle_prompter/discussions)

---

> *"Your first PR is what turns OraclePrompter from a design into a revolution."*
