# 🎯 Plugin Analysis — Card-Based Approach

## Summary

| Plugin | Card 적합도 | OS 방해 | 우선순위 |
|--------|:---:|:---:|:---:|
| 📚 Study | ⭐⭐⭐⭐⭐ | 낮음 | 🔥 지금 |
| 🔧 VibeCoding | ⭐⭐⭐⭐ | 낮음 | 다음 |
| 🎧 OraclePrompter | ⭐⭐⭐ | 높음 | 나중 |
| 🔗 Agent Gateway | ⭐⭐⭐⭐ | 중간 | 나중 |

---

## 📚 Study Plugin

### 장점
- 카드 = 플래시카드. 완벽한 궁합
- FSRS가 이미 카드 기반으로 설계됨
- ○✕가 "안다/모른다"와 정확히 일치
- 라이트너 박스 = 자연스러운 게임화
- 오디오(3유형)·수식(2유형)·텍스트(1유형) 모두 구현 완료

### 단점
- 오디오 학습은 스피커 필요 (이어폰 권장)
- 수식 렌더링은 LaTeX 파싱만으로는 한계 (full MathJax 필요할 수 있음)
- 이미지 생성 비용 (DALL-E API 필요시)

### OS 방해
- 거의 없음. 마이크만 있으면 충분.

---

## 🔧 VibeCoding Plugin

### 장점
- "WSL 설치하셨나요?" → ○✕ — 완벽한 가이드
- 초보자에게 터미널 공포증 제거
- 실패해도 스트레스 없음. 다시 시도하면 됨
- 18장 카드 = Hermes Agent 완전 설치

### 단점
- 실행은 사용자가 직접 해야 함 (Hermes 연결 전)
- 각 OS마다 가이드 분기 필요
- 설치 확인을 자동으로 할 수 없음 (사용자 신뢰)

### OS 방해
- 낮음. 가이드만 보여주므로 OS 제약 없음.

---

## 🎧 OraclePrompter Plugin

### 장점
- "도움이 되셨나요?" 카드로 즉시 피드백
- 대화 후 분석 결과를 카드로 제공
- 마인드그래프 노드를 카드로 탐색 가능

### 단점
- 실시간 코칭은 레이턴시 문제 (STT→LLM→TTS = 2~3초)
- 통화 중 마이크 접근 불가 (Android 10+)
- 녹음은 Foreground Service 필요 → OS가 죽임
- 그래프 렌더링은 모바일에서 무거움

### OS 방해
- 🔴 높음. 백그라운드·마이크·통화·배터리 모든 면에서.

---

## 🔗 Agent Gateway Plugin

### 장점
- "Hermes에게 맡길까요?" — 자연스러운 위임
- TikiTaka가 모든 에이전트의 단일 진입점
- 결과를 카드로 요약해서 보여줌

### 단점
- 네트워크 지연
- Hermes가 실행 중이어야 함 (WSL/Termux/VPS)
- 보안: SSH 키 관리 필요

### OS 방해
- 중간. 네트워크만 있으면 됨. 백그라운드 실행 시 제약.

---

## 결론

```
지금: Study Plugin 완성 (OS 방해 최소)
다음: VibeCoding Plugin (카드 적합도 최고)
나중: Agent Gateway (Hermes 연결 시)
최후: OraclePrompter (OS와의 전쟁)
```
