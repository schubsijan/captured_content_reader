// android/app/src/main/kotlin/.../MainActivity.kt
package com.example.captured_content_reader

import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.captured_content_reader/android")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "finishAndRemoveTask" -> {
                        // Löscht App komplett aus dem RAM und Verlauf (für Cold Start Overlay)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            finishAndRemoveTask()
                        } else {
                            finish()
                        }
                        result.success(null)
                    }
                    "minimizeApp" -> {
                        // Schickt App nur in den Hintergrund (wie Home-Button) - erhält State!
                        moveTaskToBack(true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
