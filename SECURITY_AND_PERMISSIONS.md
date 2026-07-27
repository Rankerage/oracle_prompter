# 🔐 Security & Permissions

## Permission Matrix (27 declared)

| Permission | Purpose | Risk | Play Review |
|-----------|---------|:---:|:---:|
| `INTERNET` | API communication | 🟢 Low | Auto-approved |
| `RECORD_AUDIO` | Mic (conversation STT) | 🔴 High | Runtime consent + Foreground Service required |
| `CAMERA` | Sight mode (Vision AI) | 🔴 High | Runtime consent + Foreground Service |
| `ACCESS_*_LOCATION` | Journal location log | 🟡 Medium | Runtime consent |
| `BLUETOOTH_*` | Earbud connection | 🟢 Low | Android 12+ runtime |
| `FOREGROUND_SERVICE_*` | Background session | 🟡 Medium | Ongoing notification required |
| `PACKAGE_USAGE_STATS` | App usage tracking | 🟡 Medium | Settings permission |
| `SYSTEM_ALERT_WINDOW` | Screen overlay | 🟡 Medium | Settings permission |

## Google Play Review Risks

### 1. Accessibility Service — High rejection risk
"Volume button detection" alone won't pass Google's "disability accessibility" requirement.
**Fix**: Replace with `MediaButtonReceiver` (official API, zero risk).

### 2. Call audio manipulation — Deceptive behavior
Google prohibits features that "deceive others."
**Fix**: Limit to VoIP calls only. Market as "AI Voice Filters." Separate into "Labs" menu.

### 3. 24/7 mic/camera — Privacy
Background sensor use requires permanent notification + explicit consent.
**Already implemented**: `OPSessionService` + ongoing notification + stop button.

## Smart Glasses External Camera

| Connection | Android Support | Current Compatibility |
|-----------|:----------:|:----------:|
| USB OTG (UVC) | ✅ Android 9+ | Auto-detected by `availableCameras()` |
| Wi-Fi Direct (RTSP) | ⚠️ Custom | Not supported by `camera` package → needs WebRTC |
| Bluetooth LE (GATT) | ⚠️ Custom | Custom plugin required |
| Manufacturer SDK | ❌ Closed | Device-specific |

## Privacy Modes

| Mode | Features | Target User |
|------|----------|------------|
| 🟢 **Local Only** | On-device AI, no internet, no API key | Default |
| 🟡 **Privacy First** | Auto-delete after 24h, AES-256 encrypted vault | Privacy-conscious |
| 🔴 **Enterprise** | Audit logs, admin console, SSO, SOC2/GDPR | Business/Government |

## Launch Checklist

- [x] AndroidManifest permissions declared
- [x] Foreground Service implemented
- [x] Runtime permission requests (permission_handler)
- [ ] Privacy Policy URL
- [ ] Accessibility Service justification → remove
- [ ] ProGuard/R8 obfuscation
- [ ] Release keystore
- [ ] Play Console Data Safety section

## Recommended: Staged Launch

```
Phase 1 (safe approval):
  ✅ INTERNET + RECORD_AUDIO + POST_NOTIFICATIONS
  ✅ "AI Whisper Conversation Coach" positioning
  ❌ Accessibility Service removed
  ❌ Call manipulation → Labs menu

Phase 2 (post-approval):
  ✅ CAMERA (Sight mode)
  ✅ BLUETOOTH (earbud coaching)
  ✅ FOREGROUND_SERVICE (24h session)

Phase 3 (mature):
  ✅ Audio effects enabled
  ✅ Smart glasses support
```
