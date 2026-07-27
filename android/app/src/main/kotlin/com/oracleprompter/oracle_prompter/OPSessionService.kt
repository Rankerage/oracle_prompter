package com.oracleprompter.oracle_prompter

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * OraclePrompter 백그라운드 세션 서비스
 *
 * 24시간 연속 세션을 유지하기 위한 Foreground Service.
 * Android 14+ 정책: 마이크/카메라를 백그라운드에서 사용하려면
 * 반드시 Foreground Service + 지속 알림이 필요.
 *
 * 사용자에게 "O.P가 활성화되어 있습니다" 알림을 항상 표시하여
 * 프라이버시 침해 우려를 해소.
 */
class OPSessionService : Service() {

    companion object {
        const val CHANNEL_ID = "op_session_channel"
        const val NOTIFICATION_ID = 1001
        const val CHANNEL_NAME = "OraclePrompter Session"
        var isRunning = false
            private set
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)

        // TODO: 실제 오디오 처리 파이프라인 시작
        // - sherpa-onnx STT 엔진
        // - Piper TTS 엔진
        // - Oboe 오디오 I/O

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW  // LOW = 소리 없음, 조용히 표시
            ).apply {
                description = "OraclePrompter가 백그라운드에서 실행 중입니다"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val contentIntent = Intent(this, MainActivity::class.java).let {
            PendingIntent.getActivity(
                this, 0, it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val stopIntent = Intent(this, OPSessionService::class.java).apply {
            action = "STOP_SERVICE"
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 1, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("OraclePrompter")
            .setContentText("O.P 세션 활성화 — 귓속말 대기 중")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(contentIntent)
            .addAction(android.R.drawable.ic_media_pause, "세션 종료", stopPendingIntent)
            .setOngoing(true)  // 사용자가 스와이프로 지울 수 없음
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }
}
