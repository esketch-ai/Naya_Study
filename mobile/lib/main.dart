import 'package:flutter/material.dart';
import 'package:ble/ble.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naya',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.emerald),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleController _ble = BleController();
  bool _isConnected = false;
  
  @override
  void initState() {
    super.initState();
    _initBle();
  }
  
  Future<void> _initBle() async {
    try {
      await _ble.start();
      
      final services = await BleService.queryServices(
        serviceIds: [
          '9E150000-B5A2-43E3-8F43-7D15A206079E',
        ],
      );
      
      if (services.isNotEmpty) {
        await BleService.connectToDevice(
          deviceId: services.first.deviceId,
          serviceIds: [
            '9E150001-B5A2-43E3-8F43-7D15A206079E', // Heart Rate
            '9E150002-B5A2-43E3-8F43-7D15A206079E', // HRV RMSSD
          ],
        );
        
        setState(() {
          _isConnected = true;
        });
      }
    } catch (e) {
      print('BLE Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Naya'),
      ),
      body: Center(
        child: _isConnected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_connected, size: 64),
                  const SizedBox(height: 16),
                  const Text('Connected to Naya Wearable'),
                  const SizedBox(height: 8),
                  const Text('Heart Rate Monitor Active'),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
