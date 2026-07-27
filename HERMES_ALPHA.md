# 🧬 OraclePrompter — Hermes + Alpha 아키텍처

> "에이전트가 에이전트를 만든다" — Hermes 구조를 O.P에 이식

---

## 패러다임: O.P는 폰 속의 Hermes다

```
Hermes Agent (데스크톱)          OraclePrompter Alpha (스마트폰)
─────────────────────────        ─────────────────────────────
🧰 Tools                         📱 Sensors
   file_read/write                  마이크, 카메라, 화면캡처, 위치
   terminal                        앱 데이터 (통화록, 문자, 캘린더)
   web_search/web_extract          Vision API, STT, TTS
   browser                         WebView 인앱 브라우저

📦 Skills                        🎭 Modes
   재사용 워크플로우 (.md)          대화 모드 (방어/설득/상쾌/통역)
                                     커뮤니티 프리셋 공유

🧠 Memory                         📝 Vault
   주입형 컨텍스트                  마인드그래프 + 마크다운 지식베이스
   facts, preferences              세션/주제/개체/일간

🔌 Providers                      🧠 AI Engines
   LLM 모델 전환                   온디바이스/API 자유 전환
   custom_providers                커스텀 엔드포인트

👤 Profiles                       📁 Sessions
   사용자 컨텍스트                  세션별 맥락 분리
   skills/plugins/cron/memories    세션 이어가기/새로 시작

⏰ Cron                           ⏰ Scheduler
   주기적 작업                     마크다운 내보내기, 일간 다이제스트
                                     앱 사용 패턴 리포트

🔍 Session Search                 🔍 Vault Search
   과거 대화 검색                  마크다운 + 임베딩 검색
   FTS5                           벡터 DB (의미 검색)
```

---

## Alpha 아키텍처

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
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │  sessions/  topics/  entities/  daily/   │   │   │
│  │  │  마인드그래프  마크다운  벡터DB  FTS5     │   │   │
│  │  └──────────────────────────────────────────┘   │   │
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

---

## Tools — 폰 센서 추상화 계층

```dart
// Hermes 스타일 Tool 인터페이스
abstract class OPTool {
  String get name;
  String get description;
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params);
}

class MicTool extends OPTool { /* STT 실행 */ }
class CameraTool extends OPTool { /* 사진 촬영 → Vision */ }
class ScreenCaptureTool extends OPTool { /* MediaProjection */ }
class LocationTool extends OPTool { /* GPS */ }
class CallLogTool extends OPTool { /* 통화록 조회 */ }
class SmsTool extends OPTool { /* 문자 조회 */ }
class CalendarTool extends OPTool { /* 일정 조회 */ }
class ContactTool extends OPTool { /* 연락처 조회 */ }
```

### Tool 실행 흐름 (Hermes 패턴)

```
User: "오늘 김철수한테 전화 왔었나?"
    │
    ▼
LLM → tool_call(name="call_log", params={query: "김철수", date: "today"})
    │
    ▼
CallLogTool.execute() → {calls: [{time: "14:30", duration: "5분"}]}
    │
    ▼
LLM → "네, 오후 2시 30분에 5분간 통화하셨습니다."
    │
    ▼
TTS → 귓속말 출력
```

---

## Skills — 마크다운 기반 재사용 워크플로우

```markdown
# skills/defense.md

---
name: defense
description: 다언증 회피 — 상대방이 스스로 전화를 끊게 유도
triggers:
  - 통화 10분 초과
  - 감지된 감정: bored, frustrated
tools:
  - mic_in (노이즈 주입)
  - tts_out (귓속말 코칭)
---

## 워크플로우

1. [감지] 상대방 발화 시간 > 전체의 80%
2. [판단] TMI 지수 85% 초과
3. [실행] 볼륨 ▼ 2회 핫키 감지 시:
   a. mic_in: white_noise(amplitude=0.3)
   b. tts_out: "지금부터 1단계 방어 작동합니다"
4. [확인] 30초 후 상대 발화량 감소 여부 체크
5. [상황] 감소 안 했으면 → 긴급 탈출 제안
```

### Skill 실행기

```dart
class SkillEngine {
  final Map<String, Skill> _skills = {};

  void loadFromMarkdown(String mdPath) {
    // YAML frontmatter + markdown body 파싱
  }

  Future<void> execute(String skillName, ToolContext ctx) async {
    final skill = _skills[skillName];
    for (final step in skill.steps) {
      final tool = ctx.getTool(step.tool);
      await tool.execute(step.params);
    }
  }
}
```

---

## Memory — Vault + MindGraph + Vector DB

```dart
// Hermes memory 패턴
class OPMemory {
  // 1. 단기 메모리 (현재 세션)
  final MindGraphProvider mindGraph;

  // 2. 장기 메모리 (영구 보존)
  final MarkdownExporter vault;

  // 3. 의미 검색
  // TODO: 벡터 임베딩 → LanceDB / SQLite-vec

  Future<void> save(String content) async {
    // 마인드그래프 노드 추가
    // vault/sessions/ 에 마크다운 저장
    // vault/topics/ 주제별 재분류
  }

  Future<List<String>> search(String query) async {
    // FTS5 전체 텍스트 검색
    // TODO: 임베딩 유사도 검색
  }
}
```

---

## Providers — AI Engine Switching

```dart
// 이미 구현됨: AiConfigProvider
// Hermes의 config.yaml providers 섹션과 동일한 개념

// provider.on_device:
//   engine: llama.cpp
//   model: gemma-3-4b.Q4_K_M.gguf
//
// provider.deepseek:
//   api_key: sk-...
//   model: deepseek-chat
```

---

## Cron — 주기적 작업

```dart
class OPScheduler {
  // Hermes cronjob 패턴
  final _jobs = <String, OPJob>{};

  void schedule(String id, String schedule, Future<void> Function() task) {
    _jobs[id] = OPJob(schedule: schedule, task: task);
  }

  void start() {
    // 1. 매일 09:00 → 앱 사용 패턴 리포트 + 일간 다이제스트
    // 2. 매주 월요일 → 주간 감정 분석
    // 3. 매월 1일 → 월간 vault 정리
  }
}
```

---

## Session Search — Vault 검색

```dart
class VaultSearch {
  // Hermes session_search 패턴
  // vault/sessions/*.md → FTS5 인덱스
  // vault/topics/*.md → 주제별 브라우징
  // vault/entities/*.md → 개체별 검색

  Future<List<String>> search(String query) async { /* FTS5 */ }
  Future<List<String>> byTopic(String topic) async { /* topics/ 디렉토리 */ }
  Future<List<String>> byEntity(String entity) async { /* entities/ 디렉토리 */ }
}
```

---

## Alpha — O.P 코어 재구성

```
lib/
  core/
    tool.dart            ← Hermes-style Tool 추상 클래스
    skill.dart           ← Skill 엔진
    memory.dart          ← 통합 메모리 (MindGraph + Vault)
    scheduler.dart       ← Cron 작업 스케줄러
    search.dart          ← Vault 검색 (FTS5)
  tools/                 ← 폰 센서 도구들
    mic_tool.dart
    camera_tool.dart
    screen_capture_tool.dart
    location_tool.dart
    call_log_tool.dart
    sms_tool.dart
    calendar_tool.dart
  skills/                ← 마크다운 스킬 파일들
    defense.md
    persuasion.md
    refresh.md
    translate.md
```

---

## 결론: Hermes → O.P Alpha

| Hermes 개념 | O.P Alpha 구현 |
|-------------|---------------|
| `tool` | `OPTool` → mic, camera, screen, location, call_log, sms, calendar |
| `skill` | `Skill` → defense.md, persuasion.md 등 마크다운 워크플로우 |
| `memory` | `OPMemory` → MindGraph + Vault + Vector DB |
| `provider` | `AiConfigProvider` → 온디바이스/API 전환 |
| `profile` | `Session` → 세션별 맥락 분리 |
| `cronjob` | `OPScheduler` → 주기적 내보내기, 다이제스트 |
| `session_search` | `VaultSearch` → FTS5 + 임베딩 검색 |
| `skill_view` | `SkillEngine.loadFromMarkdown()` |
| `config.yaml` | `SharedPreferences` + `AiProviderConfig` |

> **O.P Alpha = "폰 속의 Hermes"** — 같은 DNA, 다른 몸.
