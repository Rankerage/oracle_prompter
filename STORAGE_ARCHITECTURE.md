# 💾 OraclePrompter — 3중 저장 아키텍처

> "마크다운은 영원히. SQLite는 빠르게. 벡터는 의미로."

---

## 1. 왜 마크다운만으로는 부족한가

| 문제 | 마크다운 | 필요한 것 |
|------|:---:|------|
| "지난주 김철수 얘기" 검색 | ❌ 전체 텍스트만 가능 | 의미 검색 |
| "가장 행복했던 대화 찾기" | ❌ 메타데이터 없음 | 감정 태그 + 쿼리 |
| 수천 개 파일에서 검색 | ❌ 느림 (1초+) | 인덱싱된 검색 |
| "이 개념 처음 나온 날" | ❌ 파일 열어봐야 함 | 타임라인 쿼리 |
| LLM에 컨텍스트 주입 | ✅ 네이티브 | — |
| 10년 후에도 읽을 수 있음 | ✅ 평문 텍스트 | — |
| Git으로 버전 관리 | ✅ | — |

> **결론: 마크다운은 "영구 보존"용. 검색/분석은 SQLite + 벡터가 담당.**

---

## 2. 3중 저장 구조

```
┌──────────────────────────────────────────────────┐
│                  OPVault                          │
│                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │  📝 Markdown │  │  🗄️ SQLite   │  │ 🧬 Vector │ │
│  │  영구 보존   │  │  빠른 쿼리   │  │ 의미 검색 │ │
│  │             │  │              │  │          │ │
│  │ sessions/   │  │ sessions.db  │  │ *.vec     │ │
│  │ topics/     │  │ entities.db  │  │ (SQLite-  │ │
│  │ daily/      │  │ timeline.db  │  │  vec)     │ │
│  │ index.md    │  │              │  │          │ │
│  └─────────────┘  └──────────────┘  └──────────┘ │
│         │                │                │        │
│         └────────────────┼────────────────┘        │
│                          │                         │
│                    서로 보완                        │
└──────────────────────────────────────────────────┘
```

---

## 3. 저장 방식별 역할

### 📝 Markdown — 영구 보존

```
vault/
├── index.md               ← 항상 최신
├── sessions/
│   └── 2026-07-25_팀미팅.md  ← 원본. 절대 삭제 안 함
├── topics/
│   └── 프로젝트-OP.md        ← 주제별. 세션에서 자동 추출
├── entities/
│   └── person-김철수.md      ← 사람별. 등장 횟수, 감정 패턴
└── daily/
    └── 2026-07-25.md         ← 하루 요약
```

- **용도**: 인간이 읽는 버전. 프롬프트에 바로 주입. GitHub 백업.
- **크기**: 세션당 5-50KB. 1년 = ~100MB (압축 시 20MB)

### 🗄️ SQLite — 빠른 구조화 쿼리

```sql
-- sessions 테이블
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  start_time INTEGER,     -- Unix timestamp
  end_time INTEGER,
  duration_sec INTEGER,
  location_lat REAL,
  location_lng REAL,
  location_name TEXT,
  mood TEXT,               -- 'productive', 'tense', 'happy'
  participant_ids TEXT,    -- JSON array
  keyword_ids TEXT,        -- JSON array
  summary TEXT,            -- 200자 요약
  md_path TEXT,            -- 연결된 마크다운 경로
  word_count INTEGER,
  speaker_ratio REAL       -- 상대 발화 비율
);

-- entities 테이블
CREATE TABLE entities (
  id TEXT PRIMARY KEY,
  type TEXT,               -- 'person', 'place', 'concept'
  name TEXT,
  first_seen INTEGER,
  last_seen INTEGER,
  appearance_count INTEGER,
  average_mood TEXT,
  md_path TEXT
);

-- keywords 테이블 (FTS5)
CREATE VIRTUAL TABLE keywords_fts USING fts5(
  keyword, session_id, timestamp
);
```

- **용도**: "7월에 김철수와 한 대화 중 기분 좋았던 것" 같은 쿼리
- **크기**: 세션당 1KB 메타데이터. 1년 = ~10MB

### 🧬 Vector — 의미 검색

```sql
-- SQLite-vec 확장
CREATE VIRTUAL TABLE embeddings USING vec0(
  session_id TEXT,
  chunk_text TEXT,
  embedding FLOAT[384]  -- Gemma/All-MiniLM 임베딩
);

-- 의미 검색 쿼리
SELECT session_id, chunk_text, distance
FROM embeddings
WHERE embedding MATCH ?1
ORDER BY distance
LIMIT 5;
```

- **용도**: "지난주에 김철수가 했던 그 얘기" → 의미 기반 검색
- **크기**: 청크당 384 floats (1.5KB). 1년 = ~50MB

---

## 4. 저장소 한계 극복 전략

### 계층형 요약 (Hierarchical Summarization)

```
Level 0: 원본 (영구 보존, 마크다운)
    │
    ▼ 1시간마다
Level 1: 시간별 요약 (200자, SQLite)
    │
    ▼ 매일 자정
Level 2: 일간 다이제스트 (마크다운 + SQLite)
    │
    ▼ 매주 월요일
Level 3: 주간 다이제스트 (마크다운)
    │
    ▼ 매월 1일
Level 4: 월간 리포트 (마크다운)
```

### 저장 용량 예측

| 기간 | 원본(MD) | SQLite | Vector | 합계 |
|------|:---:|:---:|:---:|:---:|
| 1일 | 2MB | 50KB | 300KB | 2.3MB |
| 1주 | 14MB | 350KB | 2MB | 16MB |
| 1달 | 60MB | 1.5MB | 8MB | 70MB |
| 1년 | 700MB | 18MB | 100MB | 820MB |
| 10년 | 7GB | 180MB | 1GB | 8.2GB |

> 32GB 폰이면 30년치 저장 가능. 128GB 폰이면 평생 가능.

### 오래된 데이터 처리

```
90일 이상 된 원본 → 요약만 남기고 원본은 압축 아카이브
365일 이상 → 주간 다이제스트만 유지, 원본은 클라우드 백업 (선택)
```

---

## 5. 마크다운이 여전히 중심인 이유

```
"AI가 모든 기록을 누적해서 쌓아야 한다" ≠ "마크다운만으로 충분하다"

마크다운의 진짜 역할:
  ✅ LLM에 컨텍스트로 주입 (네이티브 토큰)
  ✅ 10년 후에도 메모장으로 열 수 있음
  ✅ Git diff로 인생의 변화를 추적 가능
  ✅ 오픈소스 생태계와 호환 (Obsidian, Logseq)

SQLite + Vector의 역할:
  ✅ "그때 그 얘기" 0.1초 검색
  ✅ 감정/장소/시간 복합 쿼리
  ✅ 의미 기반 추천 ("비슷한 상황에서 이렇게 했어요")
```

---

## 6. 방향 수정: 맞다. 하지만 보완한다.

| 당신의 제안 | 현재 상태 | 수정 방향 |
|-----------|---------|---------|
| "마크다운으로 모두 저장" | ✅ 맞는 방향 | + SQLite 메타데이터 |
| "모든 기록 누적" | ✅ 맞는 방향 | + 계층형 요약으로 공간 절약 |
| "AI가 맥락 생성" | ✅ 맞는 방향 | + 벡터 검색으로 의미 기반 맥락 |
| "기기 한계 우려" | ⚠️ 현실적 문제 | + 3중 저장으로 해결 (820MB/년) |

> **"마크다운은 뼈대, SQLite는 근육, 벡터는 신경"**
>
> 마크다운을 버리지 않습니다. 보완할 뿐입니다.
