package com.naya.wearable.still

import android.content.Context
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import kotlinx.coroutines.*
import java.util.concurrent.TimeUnit

class StillMotionDetectionEngine {
    companion object {
        const val STILL_THRESHOLD = 0.15f // g magnitude
        const val STILL_DURATION_MS = 60000L // 1 minute
        const val PPG_SAMPLE_DURATION_MS = 30000L // 30 seconds
        
        fun isStill(magnitude: Float): Boolean {
            return kotlin.math.abs(magnitude) < STILL_THRESHOLD
        }
    }
    
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var stillStartTime: Long? = null
    
    fun checkMotion(magnitude: Float, context: Context) {
        if (isStill(magnitude)) {
            stillStartTime?.let { startTime ->
                if ((System.currentTimeMillis() - startTime) > STILL_DURATION_MS) {
                    // Still for more than 1 minute, trigger PPG sampling
                    scope.launch {
                        samplePPG(context)
                    }
                    stillStartTime = null
                } else {
                    stillStartTime = System.currentTimeMillis()
                }
            } ?: run {
                stillStartTime = System.currentTimeMillis()
            }
        } else {
            stillStartTime = null
        }
    }
    
    private suspend fun samplePPG(context: Context) {
        // Implement PPG sampling logic here
        // This would use Wearable.DataSampleManager to request PPG data
        
        val dataSampleManager = 
            context.getSystemService(Context.WEARABLE_SERVICE) as WearableDataSampleManager
        
        val task = dataSampleManager.requestContinuousDataSamples(
            sampleDataType = SampleDataTypes.PPG,
            samplingPeriodNanos = TimeUnit.SECONDS.toNanos(30), // 30 seconds
            listener = object : WearableDataSampleListener() {
                override fun onSampleAdded(sample: DataSample) {
                    println("PPG sample added: ${sample.value}")
                    
                    // Send to backend
                    sendTelemetry(context, "ppg", sample.value)
                }
                
                override fun onSamplesDiscontinuation(sample: DataSample?) {
                    println("PPG sampling discontinued")
                }
            },
        )
        
        task.addOnCompleteListener {
            println("PPG sampling completed")
        }
    }
    
    private suspend fun sendTelemetry(context: Context, type: String, value: Any) {
        // Send telemetry to backend
        val wearableClient = WearableClient(context.applicationContext)
        
        val task = wearableClient.putDataItem(
            path = "/telemetry/$type",
            dataBundleId = "com.naya.wearable.telemetry",
            putDataRequest = PutDataRequest.Builder()
                .putDataType(type)
                .putValue(value.toString())
                .build(),
        )
        
        task.addOnSuccessListener {
            println("Telemetry sent successfully")
        }
        
        task.addOnFailureListener { e ->
            println("Failed to send telemetry: $e")
        }
    }
}
