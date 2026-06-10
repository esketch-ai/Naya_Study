//
//  ContentView.swift
//  watchApp
//
//  Naya Wearable WatchOS App Entry Point
//

import SwiftUI

@main
struct WatchApp: App {
    
    @StateObject private var bleManager = BLEManager()
    private let accelerometerEngine = AccelerometerEngine()
    private let ppgSensorService = PpgSensorService()
    
    init() {
        // Initialize sensors
        setupSensors()
    }
    
    private func setupSensors() {
        // Set up STILL detection listener
        accelerometerEngine.onStillDetected = { [weak self] minutes in
            guard let self = self else { return }
            
            print("⏸️ Device has been STILL for \(minutes) minutes")
            
            // Trigger PPG sampling when STILL > 10 minutes
            Task {
                await MainActor.run {
                    _ = self.ppgSensorService.startSampling()
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
        
        // Live Activity for lock screen widget
        #if targetEnvironment(macCatalyst) || os(watchOS)
        AugmentedRealityView()
        #endif
        
        Settings {
            SettingsView()
        }
    }
}

/// BLE Manager for wearable device connection
class BLEManager: ObservableObject {
    
    @Published var isConnected: Bool = false
    @Published var heartRate: Int?
    @Published var hrvRmssd: Double?
    @Published var activityState: DeviceActivityState?
    
    private let centralManager = CBCentralManager(delegate: self, queue: nil)
    
    func connectToDevice(device: CBPeripheral) {
        centralManager.connect(peripheral: device)
    }
}

/// CBCentralManagerDelegate implementation
extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("📶 Bluetooth state: \(central.state)")
        
        switch central.state {
        case .poweredOn:
            // Start scanning for wearable device
            startScanning()
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, error: Error?) {
        if error == nil {
            print("🔍 Discovered device: \(peripheral.name ?? "Unknown")")
            
            // Connect to discovered device
            connectToDevice(device: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("✅ Connected to wearable device")
        
        // Discover services
        peripheral.discoverServices([NayaBLEServiceUUID.service])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheralID: UUID, error: Error?) {
        isConnected = false
        print("❌ Disconnected from wearable device")
    }
}

/// ContentView for watchOS app
struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Connection status
            if !bleManager.isConnected {
                Text("Connecting...")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            } else {
                Text("Connected ✓")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
            }
            
            // Heart rate display
            if let bpm = bleManager.heartRate {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    
                    Text("\(bpm)")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("BPM")
                        .font(.system(size: 14))
                }
            }
            
            // Activity state
            if let state = bleManager.activityState {
                Text(state.description)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

/// Settings View for watchOS app
struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("BLE Service")) {
                Text("Service UUID: 9E150000-...")
                    .font(.system(size: 12))
            }
            
            Section(header: Text("Characteristics")) {
                Text("Heart Rate (UINT8)")
                Text("HRV RMSSD (FLOAT32)")
                Text("Activity State (UINT8)")
            }
        }
    }
}
