import Foundation
import CoreBluetooth
import Combine
import UIKit

class BleManager: NSObject, ObservableObject {
    static let shared = BleManager()
    
    private var centralManager: CBCentralManager!
    private var currentPeripheral: CBPeripheral?
    private var serviceUUID: UUID = UUID(string: "9E150000-B5A2-43E3-8F43-7D15A206079E")!
    
    @Published var isConnected: Bool = false
    @Published var heartRate: Double?
    @Published var hrvRmssd: Float?
    @Published var deviceActivityState: UInt8?
    
    private let heartRateUUID = UUID(string: "9E150001-B5A2-43E3-8F43-7D15A206079E")!
    private let hrvRmssdUUID = UUID(string: "9E150002-B5A2-43E3-8F43-7D15A206079E")!
    private let activityStateUUID = UUID(string: "9E150003-B5A2-43E3-8F43-7D15A206079E")!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BleManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLE State: \(central.state)")
        
        if central.state == .poweredOn {
            // Scan for devices
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: Int) {
        print("Discovered: \(peripheral.name ?? "Unknown")")
        
        if let current = currentPeripheral {
            central.cancelDiscovery(for: current)
        }
        
        currentPeripheral = peripheral
        
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        isConnected = true
        
        peripheral.discoverCharacteristics([heartRateUUID, hrvRmssdUUID, activityStateUUID], for: serviceUUID)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheralID: CBPeripheral, error: Error?) {
        print("Disconnected")
        isConnected = false
    }
}

extension BleManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices service: [CBService]) {
        print("Discovered services: \(service)")
        
        for service in service {
            if service.uuid == serviceUUID {
                print("Found Naya BLE service")
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let service = service else { return }
        
        if service.uuid == serviceUUID {
            var characteristics: [CBCharacteristic] = []
            
            for characteristic in service.characteristics {
                print("Characteristic: \(characteristic.uuid)")
                
                if characteristic.uuid == heartRateUUID {
                    characteristic.pureNotifyValue = true
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                characteristics.append(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        
        if characteristic.uuid == heartRateUUID {
            // Parse UINT8 heart rate
            let hr = CFSwapInt16BigToHost(value)
            self.heartRate = Double(hr)
            print("Heart Rate: \(hr)")
            
            // Send to backend
            sendTelemetry(type: .heartRate, value: hr)
        } else if characteristic.uuid == hrvRmssdUUID {
            // Parse FLOAT32 HRV RMSSD
            let hrv = CFSwapFloat32BigToHost(value)
            self.hrvRmssd = hrv
            print("HRV RMSSD: \(hrv)")
            
            sendTelemetry(type: .hrv, value: hrv)
        } else if characteristic.uuid == activityStateUUID {
            // Parse UINT8 device activity state
            let state = CFSwapInt32BigToHost(value) & 0xFF
            self.deviceActivityState = UInt8(state)
            print("Activity State: \(state)")
            
            sendTelemetry(type: .activity, value: Double(state))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Wrote to characteristic")
    }
}

private extension BleManager {
    func sendTelemetry(type: TelemetryType, value: Double) {
        guard let url = URL(string: "https://api.naya.app/api/wearable/log"),
              let components = URLComponents(url: url!, resolvingBase: nil),
              let queryItems = [
                  URLQueryItem(name: "type", value: type.rawValue),
                  URLQueryItem(name: "value", value: String(value))
              ] else { return }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Telemetry send failed: \(error)")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!) as? [String: Any],
               let userId = json["userId"] as? String,
               let deviceId = json["deviceId"] as? String {
                    print("Telemetry sent for user: \(userId), device: \(deviceId)")
            }
        }
        
        task.resume()
    }
}

enum TelemetryType: String {
    case heartRate = "heart_rate"
    case hrv = "hrv"
    case activity = "activity"
}
