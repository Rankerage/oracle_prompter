# 🔐 OraclePrompter — 권한·보안·스토어 심사 분석

## 1. 권한 매트릭스

| 권한 | 용도 | 위험도 | Google 심사 |
|------|------|--------|-------------|
| `INTERNET` | API 통신 | 🟢 낮음 | 자동 승인 |
| `RECORD_AUDIO` | 마이크 (대화 인식) | 🔴 높음 | 런타임 동의 + Foreground Service 필수 |
| `CAMERA` | 시선 모드 (Vision AI) | 🔴 높음 | 런타임 동의 + Foreground Service 필수 |
| `ACCESS_*_LOCATION` | 일기장 위치로그 | 🟡 중간 | 런타임 동의 |
| `BLUETOOTH_*` | 이어폰 연결 | 🟢 낮음 | Android 12+ 런타임 동의 |
| `FOREGROUND_SERVICE_*` | 백그라운드 세션 | 🟡 중간 | 지속 알림 표시 필수 |
| `POST_NOTIFICATIONS` | 알림 표시 | 🟢 낮음 | Android 13+ 런타임 동의 |

## 2. 🚨 Google Play 심사 리스크

### 2.1 Accessibility Service
- **규정**: 민감한 권한. "장애인 접근성 지원" 용도로만 허용.
- **O.P의 경우**: 볼륨 버튼 감지 목적 → **거절 확률 매우 높음**
- **해결책**:
  - 옵션 A: Accessibility Service 제거 → Media Button Receiver로 대체 (권장)
  - 옵션 B: 실제 접근성 기능 추가 (시각 장애인용 음성 안내)
  - 옵션 C: 루틴/자동화 앱 카테고리로 신청 (Tasker 스타일)

### 2.2 "통화 음질 조작" 기능
- **규정**: 기만적 행위(Deceptive Behavior) 금지
- **O.P의 경우**: 마이크 노이즈 주입 → **정책 위반**
- **해결책**:
  - 마케팅 문구에서 "통화 회피" 제거
  - "음성 강화/필터"로 포지셔닝 변경
  - VoIP 자체 통화 내에서만 작동 (일반 전화망 조작 안 함)

### 2.3 24시간 마이크/카메라
- **규정**: 백그라운드에서 민감한 센서 사용 시 "현저한 공개" 필요
- **O.P의 경우**: Foreground Service + 지속 알림으로 해결 가능
- **필수 조건**:
  - 항상 보이는 알림 (ongoing notification)
  - 알림에 "중지" 버튼
  - 개인정보처리방침에 명시

### 2.4 "대화 조작/심리전" 기능
- **규정**: 사회공학적 공격 도구로 간주될 위험
- **해결책**: "AI 대화 보조"로 포지셔닝. 노이즈 기능은 "오디오 필터 실험실"로 분류.

## 3. 🥽 스마트 안경 외부 카메라

### 3.1 Android Camera2 API
- 외부 USB/UVC 카메라: Android 9+에서 `CameraManager.getCameraIdList()`로 인식
- 안경 카메라는 USB OTG 또는 Wi-Fi Direct로 연결
- **현재 코드**: `availableCameras()`가 자동으로 외부 카메라 포함
- **제약**: 일부 제조사는 외부 카메라 차단 (삼성 DeX 등)

### 3.2 블루투스 LE 카메라
- 일부 스마트 안경(Ray-Ban Meta 등)은 BT LE로 스트리밍
- GATT 프로필 필요 → 별도 네이티브 플러그인 필요

### 3.3 Wi-Fi Direct 스트리밍
- RTSP/WebRTC로 카메라 스트림 수신
- `camera` 패키지로 직접 접근 불가 → 별도 처리 필요

## 4. 개인정보처리방침 체크리스트

- [ ] 어떤 데이터를 수집하는지 명시
- [ ] 음성 데이터는 온디바이스 처리됨을 명시
- [ ] Vision API 전송 시 이미지가 저장되지 않음을 명시
- [ ] 제3자 API(OpenAI 등) 전송 시 데이터 처리 정책 링크
- [ ] 데이터 보관 기간 (세션 단위, 마인드그래프만 로컬 저장)
- [ ] 사용자 데이터 삭제 요청 방법

## 5. 📋 스토어 출시 전 체크리스트

| 항목 | 상태 |
|------|------|
| AndroidManifest 권한 선언 | ✅ 완료 |
| Foreground Service 구현 | ✅ OPSessionService.kt |
| 런타임 권한 요청 (permission_handler) | ✅ pubspec.yaml |
| 개인정보처리방침 URL | ❌ 준비 필요 |
| Accessibility Service 정당화 | ⚠️ Google 심사 리스크 |
| proguard/r8 난독화 | ❌ 추가 필요 |
| 앱 서명 (release keystore) | ❌ 준비 필요 |
| Data safety section (Play Console) | ❌ 작성 필요 |

## 6. 권장: 권한 최소화 전략

실제 출시 시에는 **모든 기능을 한 번에 요구하지 말고 단계적으로**:

```
1차 출시 (핵심만):
  - INTERNET + RECORD_AUDIO + POST_NOTIFICATIONS
  - "AI 귓속말 대화 코치"로 포지셔닝

2차 업데이트 (고급 기능):
  - CAMERA (시선 모드)
  - BLUETOOTH (이어폰 코칭)
  - FOREGROUND_SERVICE (24시간 세션)

3차 업데이트 (실험실 기능):
  - 오디오 이펙트 ("실험실" 메뉴로 분리)
  - Accessibility Service (Media Button으로 대체 검토)
```
