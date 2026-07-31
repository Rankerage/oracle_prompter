# 🌍 TikiTaka — 6 Platforms, 1 Codebase

Flutter = 하나의 Dart 코드로 모든 OS 지원.

## 지원 플랫폼

| 플랫폼 | 명령어 | 상태 | 비고 |
|--------|--------|:---:|------|
| 📱 **Android** | `flutter build apk` | 🟢 진행 중 | Play Store 출시 예정 |
| 🍎 **iOS** | `flutter build ios` | 🟡 준비 중 | Apple 계정 필요 ($99/년) |
| 🖥️ **Windows** | `flutter build windows` | 🟢 빌드 가능 | 데스크톱 카드앱 |
| 🍏 **macOS** | `flutter build macos` | 🟢 빌드 가능 | Mac 전용 |
| 🐧 **Linux** | `flutter build linux` | 🟢 빌드 가능 | Termux/WSL/VPS |
| 🌐 **Web** | `flutter build web` | 🟢 빌드 가능 | tikitaka.study |
| 🇨🇳 **HarmonyOS** | `flutter build hap` | 🟢 Flutter 3.22+ 지원 | AppGallery (중국 시장) |

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
