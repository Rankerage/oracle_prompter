# 🃏 TikiTaka Card Principles

## 1. Card = Checkup, Not Test

```
절대 금지: "맞았어요" "틀렸어요" "정답입니다" "다시 해보세요"
오직 허용: "아세요?" → ○ (안다) / ✕ (모른다)

안다 → 다음 카드. 더 이상 묻지 않음.
모른다 → 뒷면에 설명. 나중에 다시 물어봄.

이 앱에는 '틀림'이 없습니다. '아직 모름'만 있을 뿐입니다.
```

```
모든 대화는 카드 앞면과 뒷면으로 구성된다.
긴 대화는 카드의 연속일 뿐이다.

Front:  AI의 말 (또는 사용자의 질문)
Back:   응답·설명·다음 행동 제시
```

## 2. Triangle State Machine

```
▲ (up triangle)    = 사용자가 질문할 차례
                     카드 앞면: 사용자 입력 대기
                     
▼ (down triangle)  = AI가 질문할 차례 (기본값)
                     카드 앞면: AI의 질문 표시
                     
Toggle: triangle button → 상태 전환
```

## 3. Card Sound System

```
🆕 새 카드 등장:   "탁!" (ping-pong bat hit)
🔄 카드 뒤집기:    "톡!" (lighter tap)
✅ 확인 완료:      짧은 긍정음
❌ 취소:           짧은 부정음
```

## 4. TTS Voice

```
카드 등장 → TTS로 카드 내용 읽기
사용자:
  • 볼륨 버튼 DOWN → 소리 줄임
  • ▲ "소리 안 나오게 해줘" → TTS 중지
  • 카드 뒷면: "소리가 꺼졌습니다"
```

## 5. Card Types by Flow

### Type A: Simple (1-step)
```
Front: "이 목소리 좋아요?"
Back:  "알겠습니다. 다음에 다른 목소리도 들려드릴게요."
→ Dismiss
```

### Type B: Double Confirmation (2-step)
```
Front: "영어 단어 공부 하실래요?"
Back:  "다시 한번 ○를 누르시면 시작됩니다."
       ○ → 실행
       ✕ → 취소
```

### Type C: Tutorial (always shows back)
```
Front: "O=긍정, X=부정인 거 아세요?"
Back:  "○:긍정 ✕:부정 ▲:질문"
       어떤 답이든 설명 표시
→ Dismiss
```

## 6. Card States

```
IDLE       → 카드 없음. AI가 말 걸 타이밍 기다림
PRESENTING → 카드 앞면 표시. TTS 읽는 중
FLIPPED    → 카드 뒷면 표시. 사용자 응답 대기
CONFIRMING → 2차 확인 (type B only)
DISMISSING → 카드 사라짐. 다음 카드 준비
```

## 7. Branching Logic

```
모든 카드는 tap → flip → confirm → action 순서.

Type A: tap → flip → tap → dismiss
Type B: tap → flip → tap → (execute or dismiss)
Type C: tap → flip → (always explain) → tap → dismiss
```
