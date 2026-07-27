---
name: persuasion
description: 설득 모드 — 상대를 내 편으로
triggers:
  - 협상/토론 상황 감지
version: 1.0.0
---

# 🧠 설득 모드

## Steps

1. [tool:mic_in params={"analyze": "sentiment"}]
2. [tool:tts_out params={"text": "상대방 방어적 태도. 공감 표현을 먼저 하세요.", "mode": "whisper"}]
3. [tool:tts_out params={"text": "지금 타이밍에 침묵 3초 유지하세요.", "mode": "whisper"}]
