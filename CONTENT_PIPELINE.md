# 📡 Content Pipeline — 현실적 가능성

## ✅ 가능 (지금 구현 가능)

### 📰 뉴스 파이프라인
| 소스 | 방식 | 비용 |
|------|------|:---:|
| **BBC News** | RSS (구현 완료) | 무료 |
| **Reuters** | RSS | 무료 |
| **연합뉴스** | RSS (yna.co.kr) | 무료 |
| **NewsAPI.org** | REST API (30개국) | 무료 100회/일 |
| **Google News** | ❌ 2023년 RSS 중단. NewsAPI로 대체 | — |

### 🎬 YouTube 팔로우
| 기능 | API | 비용 |
|------|-----|:---:|
| 채널 검색 | YouTube Data API v3 | 무료 10,000 units/일 |
| 최신 영상 목록 | PlaylistItems.list | 무료 |
| 채널 구독 여부 확인 | Subscriptions.list | OAuth 필요 |

### 📡 기타 가능
| 소스 | 방식 |
|------|------|
| **RSS 블로그** | 워드프레스·티스토리 RSS |
| **팟캐스트** | RSS 피드 (iTunes 등) |
| **웹툰** | 네이버·카카오 RSS (일부) |

---

## ❌ 불가능 (Meta·X 제한)

| 플랫폼 | 이유 |
|--------|------|
| **Instagram** | Meta 비즈니스 인증 필요. 개인 계정 API 차단. |
| **Facebook** | Graph API v19 이후 개인 피드 접근 불가. |
| **Twitter/X** | API v2 무료 티어 사실상 없음. $100/월 Basic. |

---

## 🎯 실현 가능한 전략

```
TikiTaka 파이프라인:

  📰 뉴스: BBC + 연합뉴스 + NewsAPI (30개국)
  🎬 YouTube: 채널 팔로우 → 최신 영상 카드
  📡 RSS: 개인 블로그·팟캐스트 구독
  🔗 X/인스타: API 대신 사용자가 링크 직접 공유
```
