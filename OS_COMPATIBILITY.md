# 🔓 OS Compatibility & Workarounds

> "Geek-friendly. Every restriction has a bypass."

---

## Android Restrictions & Workarounds

### 1. Battery Optimization (Doze Mode)

**Problem**: Android kills background services after screen-off.

**Workaround**:
```
Settings → Apps → OraclePrompter → Battery → Unrestricted
Settings → Battery → Background usage limits → Never sleeping apps → Add O.P
```

**Automated**: `Intent(ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)` → O.P opens the setting directly.

### 2. Background Service Limits (Android 12+)

**Problem**: `FOREGROUND_SERVICE` restricted on newer Android.

**Workaround**: O.P uses `FOREGROUND_SERVICE_SPECIAL_USE` with ongoing notification. Must show persistent notification with "Stop" button.

### 3. Microphone in Background

**Problem**: Android 11+ restricts background mic access.

**Workaround**: O.P uses `FOREGROUND_SERVICE_MICROPHONE` + ongoing notification. Mic stops when notification is swiped away.

### 4. Camera in Background

**Problem**: Camera cannot be used when app is in background.

**Workaround**: O.P's Sight Mode requires app to be in foreground or picture-in-picture mode.

### 5. Screen Capture (MediaProjection)

**Problem**: Requires explicit user consent every time.

**Workaround**: O.P requests once, uses `VirtualDisplay` + `ImageReader` for continuous capture.

### 6. Call Audio Manipulation

**Problem**: Android 10+ prohibits third-party apps from modifying PSTN call audio.

**Workaround**: O.P's audio effects work only on VoIP calls (in-app). PSTN manipulation disabled by default.

### 7. Notification Listener (Reading Notifications)

**Problem**: Requires `BIND_NOTIFICATION_LISTENER_SERVICE` permission.

**Workaround**: `Settings → Sound & notification → Notification access → O.P`

### 8. Usage Stats

**Problem**: `PACKAGE_USAGE_STATS` requires user to enable in Settings.

**Workaround**: `Settings → Security → Apps with usage access → O.P`

---

## Samsung One UI Specific

| Issue | Workaround |
|-------|-----------|
| Knox kills background apps aggressively | Settings → Device care → Battery → App power management → O.P → "Don't optimize" |
| Edge lighting blocks foreground service | Use standard notification channel (not heads-up) |

## Xiaomi MIUI / HyperOS Specific

| Issue | Workaround |
|-------|-----------|
| "Autostart" disabled by default | Security app → Permissions → Autostart → O.P |
| Background restrictions | Settings → Apps → O.P → Battery saver → "No restrictions" |
| "Display pop-up window" denied | Settings → Apps → O.P → "Display pop-up window" → Allow |

## Huawei HarmonyOS Specific

### Compatibility Status

| Feature | Standard Android | HarmonyOS | Notes |
|---------|:---:|:---:|------|
| Flutter framework | ✅ | ✅ | Full support via HMS Core |
| Google Play Services | ✅ | ❌ | HMS (Huawei Mobile Services) substitute |
| Camera | ✅ | ✅ | CameraX works |
| Microphone | ✅ | ✅ | AudioRecord works |
| Bluetooth | ✅ | ✅ | BT stack identical |
| Background services | ✅ | ⚠️ | Stricter than AOSP |
| Notifications | ✅ | ✅ | Push kit via HMS |
| Foreground Service | ✅ | ⚠️ | Must use HMS Foreground Service API |

### HarmonyOS Build

```bash
# Build with HMS instead of GMS
flutter build apk --target-platform android-arm64 --no-tree-shake-icons

# For Huawei AppGallery submission
flutter build appbundle
```

### Huawei-specific settings

| Issue | Workaround |
|-------|-----------|
| App launch managed by HMS | Phone Manager → App launch → O.P → "Manage manually" → all 3 toggles ON |
| Background cleanup aggressive | Settings → Battery → App launch → O.P → disable "Auto manage" |

---

## Generic Android Fork Compatibility

| OS | Based On | Compatibility |
|----|----------|:---:|
| LineageOS | AOSP | ✅ Full |
| /e/OS | LineageOS | ✅ Full (no GMS) |
| GrapheneOS | AOSP | ⚠️ Sandboxed Play Services |
| ColorOS (Oppo) | AOSP | ✅ (check battery settings) |
| Funtouch OS (Vivo) | AOSP | ✅ (check autostart) |
| OxygenOS (OnePlus) | AOSP | ✅ Full |
| Nothing OS | AOSP | ✅ Full |
| HyperOS (Xiaomi) | AOSP | ⚠️ MIUI-based restrictions |

---

## iOS (Future)

| Feature | Status |
|---------|:---:|
| Flutter framework | ✅ |
| Background mic | ❌ iOS doesn't allow (except VoIP/call apps) |
| Background camera | ❌ iOS blocks entirely |
| Earpiece audio | ⚠️ CallKit + AVAudioSession needed |
| On-device LLM | ✅ CoreML / llama.cpp iOS port |
| STT | ✅ On-device SFSpeechRecognizer |

> **iOS is NOT a current target.** O.P relies on Android-specific APIs (Foreground Service, MediaProjection, UsageStats). iOS port would be a separate project.

---

## Geek Mode Setup Checklist

For power users who want maximum functionality:

- [ ] Battery optimization → "Unrestricted"
- [ ] Autostart → Enabled
- [ ] Notification access → Granted
- [ ] Usage access → Granted  
- [ ] Display over apps → Allowed
- [ ] Background data → Unrestricted
- [ ] Do Not Disturb access → Granted (for priority notifications)
- [ ] Install SherpaTTS from F-Droid (for natural on-device TTS)
- [ ] Download GGUF model to ~/Android/data/.../models/
- [ ] Set up API keys (optional, for cloud AI)
