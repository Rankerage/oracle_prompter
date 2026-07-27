# 🎤 OraclePrompter — Voice-First + Zero-Friction 설계

> "CLI와 GUI를 구분하지 않는다. 카메라만 열면 코칭이 시작된다."

---

## 1. 최소 진입 경로

```
사용자 행동           시스템 응답
─────────────────────────────────────────
앱 아이콘 터치    →   즉시 카메라 프리뷰 (0.5초)
                     백그라운드: STT 엔진 로드 (sherpa-onnx)
                     온디바이스 LLM 웜업 (llama.cpp)

"O.P" 라고 말함  →   wake word 감지 → "Hi friend!"
                     바로 코칭 세션 시작
                     (API 키 없으면 온디바이스로 자동 폴백)
```

**터치 1회 + 말 1마디 = 코칭 시작**

---

## 2. Voice-First 명령 체계

### Wake Word: "O.P" (또는 "오라클")

```
Wake Word 감지 (DSP 레벨, 초저전력)
    │
    ▼
음성 명령어 (Intent Matching)
    │
    ├─ "방어 모드"       → defense mode ON
    ├─ "설득 모드"       → persuasion mode ON
    ├─ "무슨 소리야?"    → 현재 상황 TTS 설명
    ├─ "조용히 해"       → 일시 정지
    ├─ "다시 말해"       → 마지막 코칭 반복
    ├─ "기록해"         → 현재 세션 마크다운 저장
    ├─ "시선 모드"       → 카메라 Vision 활성화
    ├─ "화면 공유"       → MediaProjection 모드
    ├─ "Oracle"         → AI 컨설팅 모드
    ├─ "상태"           → 배터리·세션·모드 리포트
    ├─ "설정"           → 설정 화면
    └─ "종료"           → 세션 종료 + 일간 다이제스트
```

### 명령 우선순위

| 우선순위 | 명령 | 처리 방식 |
|:---:|------|---------|
| P0 | Wake word "O.P" | DSP → Open DSP chip (초저전력) |
| P1 | "방어/설득/조용히" | 로컬 intent matching (네트워크 불필요) |
| P2 | "무슨 소리야/기록해" | STT → 온디바이스 LLM 1토큰 응답 |
| P3 | "Oracle" + 질문 | API LLM (필요 시) |

---

## 3. 카메라 전용 모드 (Camera-Only)

### "카메라만 열면 코칭 시작"

```
CameraOnlyMode
    │
    ├─ 카메라 프리뷰 (480p, 15fps → 초저전력)
    ├─ 4초마다 프레임 캡처 (JPEG quality=60%)
    ├─ Vision API 또는 온디바이스 Vision (Gemma 3)
    └─ TTS 귓속말 출력
```

### 자원 사용량

| 항목 | CameraOnly | Full Mode |
|------|:---:|:---:|
| CPU | 8-12% | 20-30% |
| RAM | 300MB | 800MB |
| 네트워크 | 0 (온디바이스) | ~5MB/분 (API) |
| 배터리 | 10%/h | 20-25%/h |
| 발열 | 거의 없음 | 미온 |

---

## 4. 음성 전용 UX (No-Screen UX)

### 화면 없이도 모든 기능 사용 가능

```
사용자: "O.P"  (wake word)
   ↓
시스템: (짧은 비프음 — 듣고 있음)
   ↓
사용자: "방어 모드"
   ↓
시스템: (귓속말) "방어 모드 활성화. 볼륨 다운 두 번으로 노이즈 시작."
   ↓
사용자: (주머니 속 볼륨 ▼▼)
   ↓
시스템: (귓속말) "1단계 방어 작동 중."
```

### 음성 피드백 패턴

| 상태 | 소리 | 의미 |
|------|------|------|
| Wake word 인식 | 짧은 비프 (↑) | "듣고 있어요" |
| 명령 실행 | 짧은 비프 (↓) | "완료" |
| 에러 | 낮은 버저음 | "다시 말씀해주세요" |
| 코칭 팁 | 귓속말 TTS | 음성 안내 |
| 긴급 알림 | 진동 + 귓속말 | "긴급 탈출!" |

---

## 5. 자원 최소화 아키텍처

### 계층별 최적화

```
┌──────────────────────────────────────────┐
│  Layer 4: API (필요 시만)                 │
│  GPT-4o / Claude → deep questions only   │
│  호출 빈도: 분당 0-1회                    │
├──────────────────────────────────────────┤
│  Layer 3: 온디바이스 LLM (지속)           │
│  Gemma 3 1B (INT4) → 기본 응답            │
│  메모리: 200MB, 토큰: 15 tok/s            │
├──────────────────────────────────────────┤
│  Layer 2: STT + Vision (주기적)           │
│  Moonshine (Whisper 5x faster)            │
│  Vision: 480p, 4sec interval              │
├──────────────────────────────────────────┤
│  Layer 1: Wake Word (항상)               │
│  DSP 칩 사용 → CPU 0.5%                   │
│  배터리: 1%/h                             │
└──────────────────────────────────────────┘
```

### 메모리 예산 (4GB 기준)

| 컴포넌트 | RAM | 비고 |
|----------|:---:|------|
| OS + Flutter | 1.2GB | 고정 |
| Gemma 3 1B (INT4) | 200MB | 온디바이스 LLM |
| Moonshine STT | 80MB | Whisper 대체 |
| MindGraph (노드 100개) | 40MB | 제한적 |
| Vault (SSD) | 0 (디스크) | 마크다운 |
| 카메라 버퍼 | 50MB | 480p |
| 여유 | 2.4GB | ✅ |

---

## 6. DSP Wake Word 구현

```dart
/// VoiceInteractionService — 항상 켜진 wake word
///
/// Android VoiceInteractionService API 사용
/// → 화면 OFF 상태에서도 "O.P" 감지
/// → DSP 칩 사용 (초저전력, 1%/h)

class OPVoiceService {
  // Android:
  // <service android:name=".OPVoiceInteractionService"
  //   android:permission="android.permission.BIND_VOICE_INTERACTION">
  //   <meta-data android:name="android.voice_interaction"
  //     android:resource="@xml/voice_interaction" />
  // </service>

  // Wake word → Intent → Flutter MethodChannel
  // → OracleProvider.toggleActive()
}
```

---

## 7. 모드별 자원 프로필

| 모드 | CPU | RAM | 네트워크 | 배터리/h |
|------|:---:|:---:|:---:|:---:|
| 🎤 **Wake only** (항상) | 0.5% | 30MB | ❌ | 1% |
| 👂 **듣기 모드** (STT only) | 5% | 120MB | ❌ | 4% |
| 👁️ **시선 모드** (카메라+Vision) | 10% | 350MB | ❌/⚡ | 8% |
| 🧠 **Oracle 모드** (LLM 대화) | 20% | 500MB | ⚡ | 15% |
| 🚀 **Full 모드** (전체) | 25% | 800MB | ⚡ | 20% |
| 🌙 **절전 모드** (백그라운드) | 1% | 80MB | ❌ | 2% |

---

## 8. 스마트 안경 전환 경로

```
현재 (스마트폰)              →    미래 (안경)
──────────────────────────────────────────────
카메라: CameraController     →    안경 SDK (같은 인터페이스)
마이크: AudioRecord          →    안경 마이크 어레이
스피커: AudioTrack (이어폰)   →    골전도 스피커
Wake: DSP "O.P"              →    동일 (DSP는 안경에도 있음)
화면: Flutter UI             →    HUD 오버레이 (축소된 UI)
배터리: 4000mAh              →    200mAh (자원 최소화 필수!)
```

안경에서는 **Wake + STT + TTS** 3개의 엔진만 상주.  
나머지는 스마트폰에서 처리하고 결과만 안경으로 스트리밍.

---

## 9. 구현 체크리스트

| 상태 | 항목 |
|:---:|------|
| ✅ | CameraOnly 모드 (eye_screen.dart) |
| ✅ | 음성 명령 체계 (설계 완료) |
| ⬜ | Wake word "O.P" DSP 구현 |
| ⬜ | VoiceInteractionService |
| ⬜ | Moonshine STT 연동 |
| ⬜ | Gemma 3 온디바이스 LLM |
| ⬜ | 자원 모니터링 + 자동 모드 전환 |
