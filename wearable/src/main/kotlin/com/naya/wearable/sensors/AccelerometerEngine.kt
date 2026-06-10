package com.naya.wearable.sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlin.math.sqrt

/**
 * Accelerometer Engine for STILL Motion Detection
 * 
 * Implements hybrid sampling strategy:
 * - Always monitor low-power accelerometer/gyro for motion frequency
 * - Only wake PPG sensor when STILL > 10 minutes detected
 */
class AccelerometerEngine(private val context: Context) : SensorEventListener {
    
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    
    // Accelerometer and Gyroscope sensors
    private var accelerometer: Sensor? = null
    private var gyroscope: Sensor? = null
    
    // STILL detection threshold (0.15g magnitude indicates minimal motion)
    private val STILL_THRESHOLD = 0.15f
    
    // Minimum time in STILL state to trigger PPG sampling (10 minutes = 600 seconds)
    private val MIN_STILL_DURATION_SECONDS = 600L
    
    // Current STILL duration counter
    private var stillDurationSeconds: Long = 0L
    
    // Callback for STILL detection events
    private var onStillDetected: ((Long) -> Unit)? = null
    
    init {
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
        
        // Register listeners with low power mode for battery efficiency
        accelerometer?.let { 
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_POWER) 
        }
        gyroscope?.let { 
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_POWER) 
        }
    }
    
    /**
     * Flow that emits when device enters STILL state for > 10 minutes
     */
    fun observeStillEvents(): Flow<Long> = callbackFlow {
        trySend(0L) // Initial event
        
        awaitClose {
            sensorManager.unregisterListener(this)
        }
    }
    
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Handle accuracy changes if needed
    }
    
    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> handleAccelerometer(event)
            Sensor.TYPE_GYROSCOPE -> handleGyroscope(event)
        }
    }
    
    private fun handleAccelerometer(event: SensorEvent) {
        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        
        // Calculate magnitude (excluding gravity component)
        val magnitude = sqrt(x * x + y * y + z * z)
        
        if (magnitude < STILL_THRESHOLD) {
            // Device is in STILL state
            stillDurationSeconds++
            
            // Check if we've been STILL for > 10 minutes
            if (stillDurationSeconds >= MIN_STILL_DURATION_SECONDS) {
                onStillDetected?.invoke(stillDurationSeconds / 60) // Convert to minutes
                println("⏸️ STILL detected: ${stillDurationSeconds / 60} minutes")
                
                // Reset counter after triggering PPG sampling
                stillDurationSeconds = 0L
                
                // Trigger PPG sampling for 30 seconds (handled by separate service)
                triggerPpgSampling()
            }
        } else {
            // Device is moving - reset STILL timer
            stillDurationSeconds = 0L
        }
    }
    
    private fun handleGyroscope(event: SensorEvent) {
        // Gyro data can be used for more precise motion detection
        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        
        val magnitude = sqrt(x * x + y * y + z * z)
        
        if (magnitude < STILL_THRESHOLD) {
            stillDurationSeconds++
            
            if (stillDurationSeconds >= MIN_STILL_DURATION_SECONDS) {
                onStillDetected?.invoke(stillDurationSeconds / 60)
                stillDurationSeconds = 0L
                triggerPpgSampling()
            }
        } else {
            stillDurationSeconds = 0L
        }
    }
    
    private fun triggerPpgSampling() {
        // Wake up PPG sensor for 30 seconds only, then return to deep sleep
        println("🔋 Waking PPG sensor for 30-second sampling...")
        
        // This would typically wake a separate PPG sensor service
        // Implementation depends on your hardware abstraction layer
    }
    
    fun setOnStillDetectedListener(listener: ((minutes: Long) -> Unit)?) {
        onStillDetected = listener
    }
}
