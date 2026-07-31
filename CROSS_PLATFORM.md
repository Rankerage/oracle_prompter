# 🌍 TikiTaka — 6 Platforms, 1 Codebase

Flutter = 하나의 Dart 코드로 모든 OS 지원.

## 현재 집중 플랫폼

| 플랫폼 | 상태 | 이유 |
|--------|:---:|------|
| 📱 **Android** | 🔥 주력 | 일반 사용자 100% |
| 🖥️ **Windows** | 🟡 병행 | 당신이 쓰는 OS |
| 나머지 | ⏸️ 보류 | Android 검증 후 |

## 추후 확장

| 플랫폼 | 명령어 | 시기 |
|--------|--------|:---:|
| 🍎 iOS | `flutter build ios` | Android 안정화 후 |
| 🐧 Linux | `flutter build linux` | Termux/VPS 수요 확인 후 |
| 🍏 macOS | `flutter build macos` | iOS와 동시 |
| 🌐 Web | `flutter build web` | tikitaka.study 활성화 |
| 🇨🇳 HarmonyOS | `flutter build hap` | 중국 시장 진출 시

## 장점

- **Android에서 검증된 코드** = 모든 플랫폼에서 동일 작동
- **플러그인도 공유**: Study, VibeCoding, PhoneHelper 등 모두 호환
- **카드 UI**: 어떤 화면 크기에서도 자연스러움
- **FSRS 엔진**: 순수 Dart. 어디서든 작동

## 플랫폼별 차이

| 기능 | Android | iOS | Desktop | Web |
|------|:---:|:---:|:---:|:---:|
| 카드 인터페이스 | ✅ | ✅ | ✅ | ✅ |
| 마이크/TTS | ✅ | ✅ | ✅ | ✅ |
| 알림 읽기 | ✅ | ❌ | ❌ | ❌ |
| 앱 실행 (인텐트) | ✅ | ❌ | ❌ | ❌ |
| 손전등 | ✅ | ✅ | ❌ | ❌ |

> **핵심(카드+FSRS+LLM)은 모든 플랫폼 동일.**
> **OS 특화 기능만 플랫폼별로 분기.**
