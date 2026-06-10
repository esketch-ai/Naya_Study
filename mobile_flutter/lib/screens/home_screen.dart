import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  
  @override
  void initState() {
    super.initState();
    _initBle();
  }
  
  Future<void> _initBle() async {
    try {
      // Initialize BLE connection
      await BleService().start();
      
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
            onPressed: () => _toggleBleConnection(),
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
            Text(
              _isConnected ? 'Connected to Naya Wearable' : 'Connect your wearable device',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected ? 'Heart Rate Monitor Active' : 'Tap button to connect',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isConnected ? () => Navigator.pushNamed(context, '/learn') : null,
        icon: const Icon(Icons.school),
        label: const Text('Learn'),
      ),
    );
  }
  
  Future<void> _toggleBleConnection() async {
    if (_isConnected) {
      await BleService.disconnectFromDevice();
      setState(() => _isConnected = false);
    } else {
      await _initBle();
    }
  }
}
