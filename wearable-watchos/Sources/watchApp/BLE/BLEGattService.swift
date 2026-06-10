//
//  BLEGattService.swift
//  watchApp
//
//  Naya Wearable BLE GATT Service Implementation
//  Service UUID: 9E150000-B5A2-43E3-8F43-7D15A206079E
//

import CoreBluetooth
import Foundation

/// Naya Wearable BLE GATT Service
enum NayaBLEServiceUUID: CBUUID {
    case service = CBUUID(string: "9E150000-B5A2-43E3-8F43-7D15A206079E")
    
    case heartRateMeasurement = CBUUID(string: "9E150001-B5A2-43E3-8F43-7D15A206079E")
    case hrvRmssdValue = CBUUID(string: "9E150002-B5A2-43E3-8F43-7D15A206079E")
    case deviceActivityState = CBUUID(string: "9E150003-B5A2-43E3-8F43-7D15A206079E")
}

/// Device Activity State Enum
enum DeviceActivityState: Int, CustomStringConvertible {
    case still = 0
    case walking = 1
    case inVehicle = 2
    case sleep = 3
    
    var description: String {
        switch self {
        case .still: return "STILL"
        case .walking: return "WALKING"
        case .inVehicle: return "IN_VEHICLE"
        case .sleep: return "SLEEP"
        @unknown default: return "UNKNOWN"
        }
    }
}

/// BLE GATT Service for Naya Wearable Device
class NayaBLEGattService: CBService {
    
    private let serviceUUID = NayaBLEServiceUUID.service
    
    init() {
        super.init(
            for: serviceUUID,
            includedServices: []
        )
        
        // Add characteristics to the service
        addCharacteristic(NayaHeartRateMeasurement())
        addCharacteristic(NyaHRVRMSSDValue())
        addCharacteristic(NayaDeviceActivityState())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Heart Rate Measurement Characteristic (UINT8, Notify)
class NayaHeartRateMeasurement: CBCharacteristic {
    
    private let characteristicUUID = NayaBLEServiceUUID.heartRateMeasurement
    
    override init(
            for: CBUUID,
            properties: CBCharacteristicProperties,
            value: Data?
        ) {
        super.init(
            for: characteristicUUID,
            properties: [.read, .notify],
            value: nil
        )
        
        self.descriptors.append(NayaClientCharacteristicConfigurationDescriptor())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// HRV RMSSD Value Characteristic (FLOAT32, Notify)
class NyaHRVRMSSDValue: CBCharacteristic {
    
    private let characteristicUUID = NayaBLEServiceUUID.hrvRmssdValue
    
    override init(
            for: CBUUID,
            properties: CBCharacteristicProperties,
            value: Data?
        ) {
        super.init(
            for: characteristicUUID,
            properties: [.read, .notify],
            value: nil
        )
        
        self.descriptors.append(NayaClientCharacteristicConfigurationDescriptor())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Device Activity State Characteristic (UINT8, Notify)
class NayaDeviceActivityState: CBCharacteristic {
    
    private let characteristicUUID = NayaBLEServiceUUID.deviceActivityState
    
    override init(
            for: CBUUID,
            properties: CBCharacteristicProperties,
            value: Data?
        ) {
        super.init(
            for: characteristicUUID,
            properties: [.read, .notify],
            value: nil
        )
        
        self.descriptors.append(NayaClientCharacteristicConfigurationDescriptor())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Client Characteristic Configuration Descriptor (CCCD)
class NayaClientCharacteristicConfigurationDescriptor: CBDescriptor {
    
    private let descriptorUUID = CBUUID(string: "00002902-0000-1000-8000-00805F9B34FB")
    
    override init(for: CBUUID) {
        super.init(for: descriptorUUID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
