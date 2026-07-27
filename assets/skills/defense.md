---
name: defense
description: 다언증 회피 — 상대방이 스스로 전화를 끊게 유도
triggers:
  - 통화 시간 10분 초과
  - 상대 발화 비율 > 80%
version: 1.0.0
---

# 🛡️ 방어 모드

## Steps

1. [tool:mic_in params={"duration": 30, "analyze": true}]
2. [tool:tts_out params={"text": "상대 TMI 지수 85%. 볼륨 다운 2회를 누르세요.", "mode": "whisper"}]
3. [tool:mic_in params={"noise": "white", "amplitude": 0.3}]
4. [tool:tts_out params={"text": "1단계 방어 작동.", "mode": "whisper"}]
