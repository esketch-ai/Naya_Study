import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._();
  
  factory BleService() => _instance;
  
  bool _isConnected = false;
  BluetoothDevice? _currentDevice;
  String? _lastHeartRate;
  String? _lastHrvRmssd;
  
  StreamSubscription<BluetoothState>? _connectionStateSubscription;
  
  Future<void> start() async {
    print('Starting BLE controller...');
    
    // Start BLE scanning
    await FlutterBluePlus.startScan(
      services: ['9E150000-B5A2-43E3-8F43-7D15A206079E'],
      onResult: (device, advertisement) {
        print('Discovered Naya device: ${device.name}');
        
        // Connect to discovered device
        connectToDevice(device);
      },
    );
    
    // Listen for connection state changes
    _connectionStateSubscription = FlutterBluePlus.onConnectionStateChange.listen((state) {
      if (state == BluetoothState.connected) {
        _isConnected = true;
        print('BLE Connected to: ${_currentDevice?.name}');
      } else if (state == BluetoothState.disconnected) {
        _isConnected = false;
        print('BLE Disconnected');
      }
    });
  }
  
  Future<void> stop() async {
    print('Stopping BLE controller...');
    await FlutterBluePlus.stopScan();
    _connectionStateSubscription?.cancel();
  }
  
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _currentDevice = device;
      
      // Connect to device
      final connection = await device.connect(timeout: const Duration(seconds: 10));
      
      print('Connected to Naya BLE Service');
      
      // Discover services and characteristics
      final serviceUUID = UUID.fromString('9E150000-B5A2-43E3-8F43-7D15A206079E');
      await device.gattServer?.discoverServices([serviceUUID]);
      
      if (device.gattServer != null) {
        final service = device.gattServer!.services.firstWhere(
          (s) => s.uuid.toString() == '9E150000-B5A2-43E3-8F43-7D15A206079E',
          orElse: () => device.gattServer!.services.first,
        );
        
        // Enable notifications for heart rate (UINT8)
        final hrCharacteristic = service.characteristics.firstWhere(
          (c) => c.uuid.toString() == '9E150001-B5A2-43E3-8F43-7D15A206079E',
          orElse: () => service.characteristics.first,
        );
        
        hrCharacteristic.setNotifyValue(true);
        
        // Enable notifications for HRV RMSSD (FLOAT32)
        final hrvCharacteristic = service.characteristics.firstWhere(
          (c) => c.uuid.toString() == '9E150002-B5A2-43E3-8F43-7D15A206079E',
          orElse: () => service.characteristics.first,
        );
        
        hrvCharacteristic.setNotifyValue(true);
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

// Parse heart rate data (UINT8)
class HeartRateParser {
  static int parseHeartRate(BluetoothCharacteristicValue value) {
    if (value.data.isEmpty) return 0;
    
    // UINT8 - single byte
    final bytes = List<int>.from(value.data);
    final hr = bytes.first & 0xFF;
    
    print('Heart Rate: $hr bpm');
    return hr;
  }
}

// Parse HRV RMSSD data (FLOAT32)
class HrvParser {
  static double parseHrmssd(BluetoothCharacteristicValue value) {
    if (value.data.isEmpty) return 0.0;
    
    // FLOAT32 - 4 bytes, big-endian
    final bytes = List<int>.from(value.data);
    if (bytes.length < 4) return 0.0;
    
    final buffer = Uint8List(4)..setAll(0, bytes.sublist(0, 4));
    final hrv = buffer.float.bigEndian;
    
    print('HRV RMSSD: ${hrv.toStringAsFixed(1)} ms');
    return hrv;
  }
}

// Send telemetry to backend API
class TelemetrySender {
  static const String _baseUrl = 'https://api.naya.app/api/wearable/log';
  
  Future<void> sendTelemetry({required String type, required double value}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': type,
          'value': value.toString(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Telemetry sent successfully');
      } else {
        print('Failed to send telemetry: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending telemetry: $e');
    }
  }
  
  Future<void> sendHeartRate(int heartRate) async {
    await sendTelemetry(type: 'heart_rate', value: heartRate.toDouble());
  }
  
  Future<void> sendHrv(double hrmssd) async {
    await sendTelemetry(type: 'hrv', value: hrmssd);
  }
}
