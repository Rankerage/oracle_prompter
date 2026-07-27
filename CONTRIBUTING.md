# 🤝 OraclePrompter 기여 가이드

> **"에이전트가 에이전트를 만든다" — 함께 만들어요.**

---

## 목차
1. [첫 기여](#첫-기여)
2. [개발 환경](#개발-환경)
3. [프로젝트 구조](#프로젝트-구조)
4. [코드 스타일](#코드-스타일)
5. [PR 프로세스](#pr-프로세스)
6. [HELP WANTED](#help-wanted)
7. [행동 강령](#행동-강령)

---

## 첫 기여

### 5분 안에 개발 환경 세팅

```bash
# 1. Flutter 설치
# https://docs.flutter.dev/get-started/install

# 2. 클론
git clone https://github.com/mathe/oracle_prompter.git
cd oracle_prompter

# 3. 의존성 설치
flutter pub get

# 4. 분석
flutter analyze

# 5. 실행 (에뮬레이터 또는 실기기 연결 후)
flutter run

# 끝!
```

### 초보자를 위한 첫 PR

1. `good first issue` 라벨 찾기
2. `flutter analyze`로 현재 에러 확인
3. 작은 버그 수정부터 시작
4. `flutter format .` 으로 코드 포맷팅

---

## 개발 환경

| 항목 | 버전 |
|------|------|
| Flutter | 3.44+ |
| Dart | 3.12+ |
| Android SDK | 35+ |
| Java | 17+ (Temurin 권장) |
| Gradle | 9.1.0 |

---

## 프로젝트 구조

```
lib/
├── core/              ← Hermes DNA. 순수 Dart. 의존성 없음.
│   ├── tool.dart      ← OPTool 추상 클래스
│   ├── skill.dart     ← Skill 엔진 (마크다운→워크플로우)
│   ├── memory.dart    ← 통합 메모리
│   └── scheduler.dart ← Cron 작업
│
├── domain/            ← 도메인별 모듈 (리팩토링 중)
├── models/            ← 데이터 모델
├── providers/         ← 상태 관리 (Provider 패턴)
├── screens/           ← UI 화면 (5탭 + 온보딩)
├── services/          ← 실제 구현체 (AI, STT, TTS, Vision 등)
└── widgets/           ← 재사용 위젯
```

### 기여할 도메인 선택

| 도메인 | 디렉토리 | 난이도 |
|------|---------|:---:|
| 대화 처리 | `services/ai_service.dart` | 중급 |
| 시선 모드 | `screens/eye_screen.dart` | 중급 |
| 지식 베이스 | `services/markdown_exporter.dart` | 초급 |
| 제어 패널 | `screens/control_screen.dart` | 초급 |
| 온디바이스 LLM | `services/ai_service.dart` → JNI | 고급 |

---

## 코드 스타일

```dart
// ✅ 좋은 예
/// 마이크 입력을 STT로 변환하는 도구
class MicTool extends OPTool {
  @override String get name => 'mic_in';

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> params) async {
    // sherpa-onnx STT 실행
  }
}

// ❌ 나쁜 예
class mic extends optool { // 클래스명, 접근자 규칙 위반
  String get n => 'm'; // 의미 없는 축약
}
```

- `flutter format .` 필수
- `flutter analyze` 0 errors 필수
- 클래스/메서드에 `///` 문서화 주석
- Provider 패턴 준수 (상태 변경은 항상 notifyListeners())

---

## PR 프로세스

```
1. Issue 생성 (버그 리포트 or 기능 제안)
2. Fork → Feature Branch (feature/xxx or fix/xxx)
3. 코드 작성 + flutter format + flutter analyze
4. PR 생성 → 템플릿 작성
5. 리뷰 → 수정 → Merge
```

### PR 템플릿

```markdown
## 설명
무엇을 변경했는지 간단히.

## 관련 Issue
Closes #123

## 테스트
- [ ] flutter analyze 통과
- [ ] flutter test 통과
- [ ] Android 기기에서 테스트 완료

## 스크린샷
(UI 변경 시)
```

---

## HELP WANTED

### 🔥🔥🔥 Critical (앱이 작동하려면 반드시 필요)

| # | 태스크 | 설명 | 기술 스택 |
|---|------|------|---------|
| 1 | **llama.cpp JNI 연동** | `OnDeviceAiService`가 실제로 작동하게 | C++, JNI, Android NDK |
| 2 | **sherpa-onnx STT** | 실시간 한국어 음성인식 | C++, ONNX, Flutter FFI |
| 3 | **MediaProjection** | 폰 화면 캡처 구현 | Android SDK, MethodChannel |

### 🔥🔥 High (핵심 경험 향상)

| # | 태스크 | 설명 | 기술 스택 |
|---|------|------|---------|
| 4 | **MarkdownExporter 실제 저장** | Vault에 파일 쓰기 | Dart, File I/O |
| 5 | **SQLite 스키마** | 메타데이터 저장소 | SQLite, sqflite |
| 6 | **ForceSimulation 애니메이션** | 마인드그래프가 부드럽게 움직이게 | Dart, CustomPainter |

### 🔥 Medium (있으면 좋은 기능)

| # | 태스크 | 설명 | 기술 스택 |
|---|------|------|---------|
| 7 | **Wake word "O.P"** | VoiceInteractionService | Android, DSP |
| 8 | **SQLite-vec** | 의미 검색 | C++, SQLite 확장 |
| 9 | **Piper TTS 연동** | 온디바이스 한국어 TTS | C++, Flutter FFI |

---

## 행동 강령

### 우리는:
- ✅ **초보자를 환영합니다.** "바보 같은 질문"은 없습니다.
- ✅ **한국어/영어 모두 OK.** 이슈와 PR은 어떤 언어로든 가능.
- ✅ **실패를 축하합니다.** 망가뜨려도 괜찮아요. 다시 고치면 됩니다.
- ✅ **아이디어를 존중합니다.** "이건 어때요?" 언제든 환영.

### 우리는 하지 않습니다:
- ❌ 공격적이거나 무례한 언행
- ❌ "그건 원래 안 돼"라는 식의 부정적 피드백
- ❌ 코드 리뷰에서 인신공격

---

## 연락처

- GitHub Issues: [버그 리포트 / 기능 제안](https://github.com/mathe/oracle_prompter/issues)
- Discussions: [아이디어 토론](https://github.com/mathe/oracle_prompter/discussions)

---

> *"당신의 첫 PR이 OraclePrompter를 세상을 바꾸는 앱으로 만듭니다."*
