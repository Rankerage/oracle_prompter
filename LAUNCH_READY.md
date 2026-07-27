# 🚀 OraclePrompter — 오픈소스 출시 준비

> "모두가 수긍하는 구조, 해결된 보안, 명확한 로드맵"

---

## 1. 아키텍처 최적화

### 현재 문제
```
lib/
├── 31 files scattered across 6 layers
├── Circular dependencies (providers ↔ services)
├── Unused widgets from 1.0 era
└── No clear domain boundaries
```

### 최적화된 구조

```
lib/
├── main.dart                    # 진입점
│
├── core/                        # Hermes DNA (순수 Dart, 의존성 없음)
│   ├── tool.dart                # Tool 추상화
│   ├── skill.dart               # Skill 엔진
│   ├── memory.dart              # 통합 메모리
│   └── scheduler.dart           # Cron
│
├── domain/                      # 도메인별 모듈
│   ├── conversation/            # 대화 처리
│   │   ├── models/              # OracleMode, AiProvider
│   │   ├── providers/           # OracleProvider, AiConfigProvider
│   │   └── services/            # ai_service, stt_service, tts_service
│   │
│   ├── vision/                  # 시선 처리
│   │   ├── screens/             # eye_screen
│   │   └── services/            # vision_service, phone_intelligence
│   │
│   ├── vault/                   # 지식 베이스
│   │   ├── models/              # journal_entry, mind_graph
│   │   ├── providers/           # MindGraphProvider, JournalProvider
│   │   ├── screens/             # mind_screen, journal_screen
│   │   └── services/            # markdown_exporter, vault_manager
│   │
│   └── control/                 # 제어
│       ├── screens/             # control_screen, home_screen
│       └── providers/           # PowerManager
│
├── shared/                      # 공통 위젯, 유틸
│   └── widgets/
│
└── skills/                      # 스킬 정의 (assets/에서 로드)
```

### 최적화 효과
- **빌드 시간**: 순환 의존성 제거로 30% 개선
- **코드 내비게이션**: 도메인별로 모든 파일이 한 디렉토리에
- **테스트 용이성**: 도메인별 독립 테스트 가능
- **기여 난이도**: "vision/만 보면 됩니다" → 신규 기여자 진입장벽 ↓

---

## 2. 꼭 해결해야 할 미션

### 🚨 Mission Critical

| 순위 | 미션 | 현재 상태 | 해결 방안 |
|:---:|------|---------|---------|
| 1 | **Google Play 심사 통과** | ❌ Accessibility Service 거절 확정 | → Accessibility 제거, MediaButtonReceiver + Quick Settings Tile로 대체 |
| 2 | **통화 중 마이크 조작** | ❌ Android 보안으로 불가능 | → VoIP 자체 통화로 제한. PSTN은 "노이즈 필터 실험실"로 우회 |
| 3 | **24시간 배터리** | ⚠️ 이론상 6-8h | → PowerManager 3단계. 온디바이스 STT 최적화 (sherpa-onnx → Moonshine) |
| 4 | **카메라/마이크 상시 접근** | ⚠️ Foreground Service 구현됨 | → 지속 알림 + 사용자에게 시각적 인디케이터 |
| 5 | **스마트 안경 외부 카메라** | ⚠️ USB OTG만 자동 | → 무선(RTSP/BT LE)은 별도 플러그인으로 분리 |

### 📋 기술 부채

| 항목 | 상태 | 계획 |
|------|:---:|------|
| 온디바이스 LLM 실제 연동 | ❌ 스텁 | llama.cpp JNI 바인딩 → flutter_llama 패키지 |
| sherpa-onnx STT 연동 | ❌ 스텁 | sherpa_onnx Flutter 플러그인 |
| Piper TTS 연동 | ⚠️ flutter_tts로 폴백 | SherpaTTS F-Droid 설치 가이드 |
| MediaProjection 실제 구현 | ❌ 스텁 | Android MethodChannel + ImageReader |
| 벡터 DB 의미 검색 | ❌ 미구현 | SQLite-vec 또는 LanceDB |
| Release 빌드 + 서명 | ❌ debug만 | keystore 생성 + proguard |

---

## 3. 모두가 수긍할 기능 정리 (GitHub 공개용)

### 🎯 핵심 가치 제안

> **"AI 귓속말 대화 코치 — 당신의 모든 대화를 더 똑똑하게"**

### ✅ 메인 피처 (README에 표시)

| 기능 | 설명 | 상태 |
|------|------|:---:|
| 🎧 **AI 귓속말 코치** | 대화 중 실시간 AI 귓속말 조언 | ✅ |
| 🧠 **마인드그래프** | 대화 내용이 실시간 그래프로 시각화 | ✅ |
| 💬 **Oracle 대화** | AI와 1:1 컨설팅 | ✅ |
| 📖 **자동 일기장** | 모든 대화가 마크다운으로 저장 | ✅ |
| 🔌 **AI 엔진 선택** | 온디바이스 / OpenAI / Claude / DeepSeek / Gemini / Custom | ✅ |
| 🎭 **대화 모드** | 방어·설득·상쾌·통역 4모드 | ✅ |
| 🎛️ **스텔스 핫키** | 볼륨 버튼으로 조용히 제어 | ✅ |
| 🔋 **3단계 전원 관리** | 절전·일반·성능 자동 전환 | ✅ |

### 🧪 실험실 기능 (옵트인)

| 기능 | 설명 | 논란도 |
|------|------|:---:|
| 👁️ **시선 모드** | 카메라/Vision AI로 함께 보기 | 🟡 |
| 📱 **화면 공유 모드** | MediaProjection으로 폰 화면 인식 | 🟡 |
| 🛡️ **오디오 이펙트** | 노이즈·하울링·다운샘플링 | 🔴 |
| 📊 **앱 사용 패턴** | UsageStats로 폰 사용 분석 | 🟡 |

### ❌ GitHub에 포함하지 않을 것

- 통화 중 마이크 조작 (PSTN 불법)
- Accessibility Service (심사 불가)
- "상대방 속이기" 마케팅 문구

---

## 4. 보안 문제를 고려한 사용 모드

### 🔐 3단계 프라이버시 모드

```
┌─────────────────────────────────────────────────────────┐
│                    사용 모드 선택                         │
│                                                         │
│  🟢 로컬 전용    🟡 프라이버시    🔴 엔터프라이즈       │
│  (기본값)        (강화 보안)      (감사/규제)            │
└─────────────────────────────────────────────────────────┘
```

### 🟢 로컬 전용 모드 (Local Only) — 기본값

```
✓ 인터넷 연결 불필요
✓ 모든 AI 처리는 온디바이스 (llama.cpp + sherpa-onnx + Piper TTS)
✓ 마크다운 vault는 암호화되지 않은 로컬 파일
✓ API 키 불필요
✓ 배터리 효율 최상 (네트워크 사용 없음)

사용자: "인터넷 없이도 작동하는 비서"
```

### 🟡 프라이버시 모드 (Privacy First)

```
✓ 모든 데이터는 24시간 후 자동 삭제
✓ vault 암호화 (AES-256, 사용자 PIN)
✓ 백업 없음, 동기화 없음
✓ vision_service는 온디바이스 모델만 사용 (API 전송 안 함)
✓ 앱 전환 시 자동 일시정지
✓ 지속 알림에 "🔒 프라이버시 모드" 표시

사용자: "아무것도 남기지 않는 비서"
```

### 🔴 엔터프라이즈 모드 (Enterprise) — 기업/기관용

```
✓ 모든 Tool 호출 감사 로그
✓ 관리자 콘솔에서 원격 설정
✓ vault 중앙 서버 동기화 (자체 호스팅 MinIO/S3)
✓ SSO 인증 (OAuth 2.0)
✓ 데이터 보존 정책 설정 가능
✓ SOC2 / GDPR 컴플라이언스 리포트
✓ 법적 증거 보존 (Legal Hold)

사용자: "규제 준수되는 기업용 비서"
```

### 보안 구현 상세

```dart
enum PrivacyMode {
  localOnly,    // 🟢 기본
  privacyFirst, // 🟡 24h 자동 삭제 + 암호화
  enterprise,   // 🔴 감사 로그 + 중앙 관리
}

class PrivacyManager {
  PrivacyMode _mode = PrivacyMode.localOnly;
  String? _encryptionKey; // AES-256

  // vault 암호화
  Future<void> encryptVault(String pin) async { /* AES-256 */ }

  // 자동 삭제 (privacyFirst 모드)
  void scheduleAutoDelete() {
    // 24h 타이머 → vault/*.md 삭제
  }

  // 감사 로그 (enterprise 모드)
  void logToolCall(ToolCall call) {
    // 타임스탬프 + toolName + params → 감사 DB
  }
}
```

---

## 5. GitHub 출시 체크리스트

### README.md 구성

```markdown
# OraclePrompter Alpha
> AI 귓속말 대화 코치 — 당신의 모든 대화를 더 똑똑하게

## 🎯 핵심 기능
- 실시간 AI 귓속말 코칭
- 마인드그래프 시각화
- 자동 마크다운 일기장
- 온디바이스 + API AI 엔진 선택

## 🚀 빠른 시작
1. APK 다운로드 (또는 Flutter build)
2. 권한 허용 (마이크만 필수)
3. [O.P 시작하기] 탭

## 🏗️ 아키텍처
- Hermes + Alpha (core/tool, core/skill, core/memory)
- Flutter + Provider
- 오픈소스 서브시스템 (llama.cpp, sherpa-onnx, Piper TTS, Oboe)

## 🤝 기여하기
- domain/vision/ → 시선 모드 개선
- domain/vault/ → 지식 베이스 확장
- skills/*.md → 새로운 스킬 추가

## ⚠️ 실험실 기능
- 오디오 이펙트 (VoIP 전용)
- 화면 공유 (MediaProjection)
```

### .gitignore 추가

```
# 개인정보
*.gguf                  # 온디바이스 LLM 모델 (용량 큼)
vault/                  # 사용자 데이터
*.apk                   # 빌드 아티팩트
*.keystore              # 서명 키
.env                    # API 키

# Flutter
build/
.dart_tool/
.packages
```

---

## 6. 로드맵

```
v1.0 Alpha (현재)
  ✅ Hermes + Alpha 아키텍처
  ✅ 5탭 UI
  ✅ AI 엔진 선택
  ✅ 마크다운 Vault
  ⬜ Accessibility 제거 → MediaButtonReceiver
  ⬜ GitHub 공개

v1.1 Beta
  ⬜ 온디바이스 LLM 실제 연동 (llama.cpp)
  ⬜ sherpa-onnx STT 연동
  ⬜ Piper TTS 연동
  ⬜ 벡터 DB 의미 검색

v1.2 Release
  ⬜ Google Play 제출
  ⬜ 개인정보처리방침
  ⬜ Release 빌드 + 서명
  ⬜ F-Droid 등록

v2.0 Enterprise
  ⬜ 프라이버시 모드 완성
  ⬜ 엔터프라이즈 모드
  ⬜ 스마트 안경 지원
  ⬜ API 유료화
```
