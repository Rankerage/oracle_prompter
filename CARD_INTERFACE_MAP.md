# 🃏 Card Interface — Complete Application Map

> "Every binary decision in this app is a card. No dialogs. No toggles. No settings fatigue."

---

## Currently Card-ified ✅

| Context | Card |
|---------|------|
| Voice preference | "이 목소리, 듣기 편하실 거예요?" |
| Learning check | "Geek이 무슨 뜻인지 아세요?" |
| English practice | "이 소리 들리세요?" → 텍스트 공개 |
| Feature discovery | "시선 모드를 켜볼까요?" |
| API balance | "잔액이 부족해요. 온디바이스로 전환할까요?" |
| Mood check | "지금 기분이 괜찮으세요?" |
| Model download | "AI 모델을 다운로드할까요?" |

---

## Candidate: Replace These UIs with Cards 🔄

### 1. Settings → Cards

| Current UI | Card Replacement |
|-----------|-----------------|
| Toggle: Wi-Fi only API | "Wi-Fi에서만 API를 쓸까요?" |
| Toggle: On-device first | "온디바이스를 먼저 써볼까요?" |
| Slider: Vision interval | "화면 분석을 더 자주 할까요?" |
| Switch: Mic when screen OFF | "화면 꺼져도 계속 들을까요?" |

### 2. Dialogs → Cards

| Current UI | Card Replacement |
|-----------|-----------------|
| Alert: Error | "API 연결이 끊겼어요. 온디바이스로 전환할까요?" |
| Confirm: Delete | "이 기록을 정말 지울까요?" |
| Confirm: Exit | "앱을 종료할까요? 백그라운드에서 계속 도와드릴게요." |

### 3. MindGraph → Cards

| Trigger | Card |
|---------|------|
| Tap node | "이 개념에 대해 더 알아볼까요?" |
| New cluster detected | "새로운 주제 '여행'이 발견됐어요. 따로 모아볼까요?" |
| Graph full | "그래프가 꽉 찼어요. 오래된 노드를 정리할까요?" |

### 4. Navigation → Cards

| Context | Card |
|---------|------|
| New journal entry ready | "오늘의 일기가 작성됐어요. 보러 갈까요?" |
| Long time in one tab | "마인드 그래프가 업데이트됐어요. 확인할까요?" |
| Session end | "세션을 마치고 일간 다이제스트를 만들까요?" |

### 5. Notifications → Cards

| Trigger | Card |
|---------|------|
| Incoming call (during focus) | "지금 통화 중요한 내용일 것 같아요. 받을까요?" |
| Calendar reminder | "30분 후 약속이 있어요. 준비할까요?" |
| Battery low | "배터리가 15%예요. 절전 모드로 바꿀까요?" |

### 6. AI Model → Cards

| Trigger | Card |
|---------|------|
| Slow response detected | "응답이 느려졌어요. 더 가벼운 모델로 바꿀까요?" |
| Better model available | "새 모델이 나왔어요. 업그레이드할까요?" |
| Cost warning | "이번 달 API 사용량이 많아요. 제한할까요?" |

### 7. Sharing & Social → Cards

| Trigger | Card |
|---------|------|
| Interesting insight found | "재미있는 패턴을 발견했어요. 저장할까요?" |
| Learned preference | "음성 피드백을 더 자주 드릴까요?" |

---

## New Card Types to Implement 🆕

### A/B Choice Card
```
"이 목소리" vs "저 목소리"
   [A]          [B]
→ Pick one, both play a sample
```

### Slider Card
```
"분석 속도"
 [느리게] ──●── [빠르게]
→ Continuous choice, not binary
```

### Multi-Card Sequence
```
Card 1: "운동 좋아하세요?" → [네]
Card 2: "어떤 운동을 주로 하세요?" → [달리기] [수영] [헬스]
→ Branching based on previous answers
```

---

## Architecture: CardRouter

```dart
/// Routes ALL binary decisions through cards
class CardRouter {
  static void ask(BuildContext ctx, CardDecision decision) {
    showCard(ctx,
      type: decision.type,
      statement: decision.statement,
      backAnswer: decision.back,
      pos: decision.posLabel, neg: decision.negLabel,
      onResult: (confidence) => decision.onResult?.call(confidence),
    );
  }
}

class CardDecision {
  final CardType type;
  final String statement, back, posLabel, negLabel;
  final void Function(int confidence)? onResult;
}
```

---

## Rule: When to Use a Card

```
if (decision has exactly 2 options
    && user doesn't need to see context to decide
    && can be phrased as a recommendation, not a question) {
  → USE A CARD
} else {
  → USE TRADITIONAL UI
}
```

---

## Anti-Patterns (DON'T card-ify)

- ❌ "어떤 앱을 실행할까요?" (not binary)
- ❌ "파일 이름을 입력하세요" (needs text input)
- ❌ "전체 설정을 확인하세요" (too many options)
