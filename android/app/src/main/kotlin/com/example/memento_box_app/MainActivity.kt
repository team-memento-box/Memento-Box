package com.example.memento_box_app
 
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.kakao.sdk.common.KakaoSdk
import io.flutter.embedding.android.FlutterActivity
import com.kakao.sdk.common.util.Utility
 
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            KakaoSdk.init(this, "4707b0b21793e9563d575dcdbdbbb168")
        } catch (e: Exception) {
            e.printStackTrace()
        }
 
        // 🔽 여기에 추가!
        val keyHash = Utility.getKeyHash(this)
        Log.d("KeyHash", "***Kakao Key Hash***: $keyHash")
    }
 
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.d("MainActivity", "🔥 onNewIntent called with intent: ${intent.data}")
    }
}