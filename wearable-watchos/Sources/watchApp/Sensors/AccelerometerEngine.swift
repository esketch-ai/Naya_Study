//
//  AccelerometerEngine.swift
//  watchApp
//
//  Naya Wearable Accelerometer Engine for STILL Motion Detection
//  Implements low-power hybrid sampling strategy
//

import CoreMotion
import Foundation

/// STILL Motion Detection Configuration
struct StillDetectionConfig {
    /// Magnitude threshold below which device is considered STILL (in g)
    let stillThreshold: Float = 0.15
    
    /// Minimum duration in STILL state to trigger PPG sampling (seconds)
    let minStillDurationSeconds: TimeInterval = 600 // 10 minutes
    
    /// Sampling rate for accelerometer (UIEventRate is power efficient)
    let samplingRate: CMAccelerometerSamplingRate = .uiEventRate
}

/// Accelerometer Engine for STILL Motion Detection
class AccelerometerEngine {
    
    private let config: StillDetectionConfig
    private var motionManager: CMMotionManager!
    private var accelerometerDataQueue: [CMAccelData] = []
    
    // STILL detection state
    private var isStill: Bool = false
    private var stillStartTime: Date?
    private var stillDurationSeconds: TimeInterval = 0
    
    /// Callback for STILL detection events (emitted every minute after threshold reached)
    var onStillDetected: ((minutes: Int) -> Void)?
    
    init(config: StillDetectionConfig = StillDetectionConfig()) {
        self.config = config
    }
    
    func start() {
        motionManager.accelerometer = CMAccelerometerDataHandler { [weak self] data, handler in
            self?.handleAccelerometer(data: data)
            handler.process()
        }
        
        // Start accelerometer with low-power sampling rate
        motionManager.startAccelerometer(
            samplingRate: config.samplingRate,
            updateInterval: 1.0
        )
        
        print("📊 Accelerometer engine started (low-power mode)")
    }
    
    func stop() {
        motionManager.stopAccelerometer()
        print("⏸️ Accelerometer engine stopped")
    }
    
    private func handleAccelerometer(data: CMAccelData) {
        let magnitude = sqrt(
            data.acceleration.x * data.acceleration.x +
            data.acceleration.y * data.acceleration.y +
            data.acceleration.z * data.acceleration.z
        )
        
        if magnitude < config.stillThreshold {
            // Device is in STILL state
            if !isStill {
                isStill = true
                stillStartTime = Date()
            }
            
            let now = Date()
            stillDurationSeconds = now.timeIntervalSince(stillStartTime ?? now)
            
            // Check if we've been STILL for > 10 minutes
            if stillDurationSeconds >= config.minStillDurationSeconds {
                onStillDetected?(minutes: Int(stillDurationSeconds / 60))
                
                // Reset state after triggering PPG sampling
                isStill = false
                stillStartTime = nil
                stillDurationSeconds = 0
                
                print("⏸️ STILL detected for \(Int(stillDurationSeconds / 60)) minutes")
            }
        } else {
            // Device is moving - reset STILL state
            isStill = false
            stillStartTime = nil
            stillDurationSeconds = 0
        }
    }
}
