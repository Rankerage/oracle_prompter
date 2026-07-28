# 🧬 Hermes DNA → TokTok — 완전 이식

## 1. Memory = 사용자 취향 마크다운

```
vault/
├── index.md              ← 모든 것의 관문
├── memory/
│   ├── preferences.md    ← 목소리·속도·테마 선호
│   ├── interests.md      ← 관심사·취미·유머 취향
│   └── learning.md       ← 학습 스타일·강점·약점
├── sessions/
│   ├── 2026-07-28.md     ← 오늘의 모든 카드 응답
│   └── ...
├── skills/
│   ├── english.md        ← 영어 학습 스킬
│   └── korean-slang.md   ← 신조어 학습 스킬
├── tools/
│   └── available.md      ← 현재 활성화된 도구 목록
└── cron/
    └── schedule.md       ← 예정된 학습·체크인
```

## 2. 메모리는 선언적 사실만

```
❌ "매일 영어 공부 카드를 보여줘라"
✅ "사용자는 오후 10시에 영어 학습을 선호함"
```

## 3. AI가 읽는 방식

```
세션 시작 → vault/index.md 읽기 → 7개 파일 참조 → 맞춤 컨텍스트 주입
→ "이 사용자: 빠른 여성 목소리, IT 관심, 저녁에 공부 잘함"
```

---

## 4. Skill = 마크다운 워크플로우

```yaml
---
name: english-listening
description: 영어 듣기 훈련 (텍스트 없이 소리만)
triggers:
  - 사용자 요청 "영어"
  - 학습 시간 22:00 도달
  - interest.영어 > 0.6
---
# 영어 듣기 훈련

1. AudioLevelEngine으로 난이도 설정
2. 소리 재생 → "들려요?" [✕] [○]
3. 응답 → FSRS.reviewCard()
4. 3회 연속 ○ → 난이도 상승
```

---

## 5. Session Search = 모든 카드 응답 검색 가능

```
"지난주에 내가 싫다고 한 목소리는 뭐였지?"
→ vault/sessions/ 검색 → "빠른 남성 목소리 ✕"
→ AI가 참조 → "저번에 빠른 남성 목소리는 싫어하셨어요."
```

---

## 6. 구조가 AI를 돕는 이유

```
구조 없음:
  AI: "음... 사용자가 뭘 좋아하는지 모르겠다."
  → 무작위 카드. 낮은 적중률.

구조 있음:
  AI: "vault/memory/preferences.md 참조 → 음성: 여성 느림.
       vault/sessions/2026-07-28.md → 오늘 영어 ○ 8회.
       vault/cron/schedule.md → 22:00 영어 시간.
       → 지금 영어 단어 카드 보여주자."
  → 정확한 타이밍. 높은 만족도.
```
