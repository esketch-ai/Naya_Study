import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._();
  
  factory BleService() => _instance;
  
  bool _isConnected = false;
  BluetoothDevice? _currentDevice;
  
  Future<void> start() async {
    print('Starting BLE controller...');
    await FlutterBluePlus.start();
    
    // Scan for Naya wearable devices
    FlutterBluePlus.onConnectionStateChange.listen((state) {
      if (state == BluetoothState.connected) {
        _isConnected = true;
        print('BLE Connected');
      } else if (state == BluetoothState.disconnected) {
        _isConnected = false;
        print('BLE Disconnected');
      }
    });
    
    // Scan for devices with Naya BLE service UUID
    await FlutterBluePlus.startScan(
      services: ['9E150000-B5A2-43E3-8F43-7D15A206079E'],
      onResult: (device, advertisement) {
        print('Discovered device: ${device.name}');
        
        // Connect to discovered device
        connectToDevice(device);
      },
    );
  }
  
  Future<void> stop() async {
    print('Stopping BLE controller...');
    await FlutterBluePlus.stopScan();
  }
  
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _currentDevice = device;
      
      final serviceUUID = UUID.fromString('9E150000-B5A2-43E3-8F43-7D15A206079E');
      await device.connect(timeout: const Duration(seconds: 10));
      
      // Discover services and characteristics
      final service = await device.gattServer?.discoverServices([serviceUUID]);
      
      if (service != null) {
        print('Connected to Naya BLE Service');
        
        // Enable notifications for heart rate and HRV
        final hrCharacteristic = service.characteristics.firstWhere(
          (c) => c.uuid.toString() == '9E150001-B5A2-43E3-8F43-7D15A206079E',
          orElse: () => service.characteristics.first,
        );
        
        hrCharacteristic.setNotifyValue(true);
      }
      
      _isConnected = true;
    } catch (e) {
      print('Connection error: $e');
      _isConnected = false;
    }
  }
  
  static Future<void> disconnectFromDevice() async {
    print('Disconnecting from BLE device');
    // Implementation to disconnect
  }
}
