package com.naya.wearable

import android.app.Application
import android.content.Context
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.ProcessLifecycleOwner
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class WearableApp : Application() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize lifecycle monitoring
        ProcessLifecycleOwner.get().lifecycle.addObserver(LifecycleMonitor())
        
        println("🦴 Naya Wearable App initialized")
    }
    
    inner class LifecycleMonitor : LifecycleObserver {
        @OnLifecycleEvent(Lifecycle.Event.ON_START)
        fun onForeground() {
            println("⌚ Wearable app came to foreground")
        }
        
        @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
        fun onBackground() {
            println("⌚ Wearable app went to background")
        }
    }
}
