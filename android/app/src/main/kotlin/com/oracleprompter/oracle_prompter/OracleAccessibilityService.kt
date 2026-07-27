package com.oracleprompter.oracle_prompter

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent

/**
 * OraclePrompter Accessibility Service
 *
 * 볼륨 버튼 이벤트를 감지하여 핫키 명령을 처리합니다.
 * - 볼륨 다운 2회 연속 (1초 이내): 1단계 방어
 * - 볼륨 다운 3초 길게: 긴급 탈출
 * - 볼륨 업 2회 연속: 원상 복구
 */
class OracleAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "OracleAccessibility"
        private const val DOUBLE_CLICK_WINDOW_MS = 1000L
        private const val LONG_PRESS_MS = 3000L
    }

    private var lastVolDownTime = 0L
    private var lastVolUpTime = 0L
    private var volDownPressStart = 0L
    private var isVolDownPressed = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i(TAG, "OraclePrompter Accessibility Service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Not needed for key events
    }

    override fun onInterrupt() {
        Log.i(TAG, "Service interrupted")
    }

    override fun onKeyEvent(event: KeyEvent): Boolean {
        val keyCode = event.keyCode

        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            handleVolumeDown(event)
            return true
        }

        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            handleVolumeUp(event)
            return true
        }

        return super.onKeyEvent(event)
    }

    private fun handleVolumeDown(event: KeyEvent) {
        if (event.action == KeyEvent.ACTION_DOWN) {
            val now = System.currentTimeMillis()

            // 더블 클릭 체크
            if (now - lastVolDownTime <= DOUBLE_CLICK_WINDOW_MS && lastVolDownTime > 0) {
                Log.i(TAG, "Volume Down DOUBLE CLICK → Defense Level 1")
                sendCommand("defense_1")
                lastVolDownTime = 0
            } else {
                lastVolDownTime = now
            }

            // 길게 누르기 시작
            volDownPressStart = now
            isVolDownPressed = true
        } else if (event.action == KeyEvent.ACTION_UP) {
            val duration = System.currentTimeMillis() - volDownPressStart
            isVolDownPressed = false

            if (duration >= LONG_PRESS_MS) {
                Log.i(TAG, "Volume Down LONG PRESS ${duration}ms → Emergency Escape!")
                sendCommand("emergency_escape")
            }
        }
    }

    private fun handleVolumeUp(event: KeyEvent) {
        if (event.action == KeyEvent.ACTION_DOWN) {
            val now = System.currentTimeMillis()

            if (now - lastVolUpTime <= DOUBLE_CLICK_WINDOW_MS && lastVolUpTime > 0) {
                Log.i(TAG, "Volume Up DOUBLE CLICK → Restore Normal")
                sendCommand("restore")
                lastVolUpTime = 0
            } else {
                lastVolUpTime = now
            }
        }
    }

    private fun sendCommand(command: String) {
        // Flutter와 통신: MethodChannel 또는 EventChannel
        // 현재는 로그만 출력 (네이티브 통신은 추후 구현)
        Log.i(TAG, "Command: $command")
        // TODO: Flutter와 통신하여 OracleProvider.setHotkeyLevel() 호출
    }
}
