import 'package:flutter/material.dart';
import '../services/ble_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _ble = BleService();
  bool _isConnected = false;
  int? _heartRate;
  
  @override
  void initState() {
    super.initState();
    _initBle();
  }
  
  Future<void> _initBle() async {
    try {
      await _ble.start();
      
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      print('BLE Initialization Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naya~'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _toggleBleConnection,
            tooltip: 'Connect/Disconnect Wearable',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              size: 80,
              color: _isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            
            // Connection status text
            Text(
              _isConnected 
                  ? 'Connected to Naya Wearable' 
                  : 'Connect your wearable device',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 8),
            
            // Heart rate display
            if (_heartRate != null) ...[
              Text(
                'Heart Rate: $_heartRate bpm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Instructions for disconnected state
            if (!_isConnected) ...[
              Text(
                'Tap button to connect',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initBle,
                icon: const Icon(Icons.bluetooth_connected),
                label: const Text('Connect Device'),
              ),
            ],
          ],
        ),
      ),
      
      // Floating action button to navigate to Learn screen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isConnected ? () => Navigator.pushNamed(context, '/learn') : null,
        icon: const Icon(Icons.school),
        label: const Text('Learn'),
      ),
    );
  }
  
  Future<void> _toggleBleConnection() async {
    if (_isConnected) {
      // Disconnect from device
      await BleService.disconnectFromDevice();
      setState(() => _isConnected = false);
      print('Disconnected from BLE device');
    } else {
      // Reconnect to device
      await _initBle();
    }
  }
}

// Heart rate listener (would be implemented with StreamBuilder in production)
class HeartRateListener {
  static void onHeartRateChanged(int heartRate) {
    print('Heart Rate updated: $heartRate bpm');
    
    // Send telemetry to backend
    TelemetrySender.sendHeartRate(heartRate);
  }
}

// Activity state listener (would be implemented with StreamBuilder in production)
class ActivityStateListener {
  static void onActivityStateChanged(int state) {
    print('Device activity state: $state');
    
    // Send telemetry to backend
    TelemetrySender.sendTelemetry(
      type: 'activity', 
      value: state.toDouble()
    );
  }
}
