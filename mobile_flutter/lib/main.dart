import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naya~',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.emerald),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
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
  final BleService _ble = BleService();
  bool _isConnected = false;
  
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

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final LearningService _learning = LearningService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _learning.getZombieCards(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text('No cards available'),
                  const SizedBox(height: 8),
                  Text('Connect your wearable device to start learning',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          
          final cards = snapshot.data!;
          
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(Icons.school, color: Colors.emerald),
                  title: Text(card['expression'] ?? 'Loading...'),
                  subtitle: Text(card['meaning'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => _submitAnswer(context, card),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Future<void> _submitAnswer(BuildContext context, Map<String, dynamic> card) async {
    // Show confirmation dialog before submitting
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card['expression'] ?? ''),
            const SizedBox(height: 8),
            Text('Meaning: ${card['meaning']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit answer (answerIndex = 0 for correct in this demo)
              _learning.submitQuiz(card['id'] ?? '', 0);
              Navigator.pop(context, {'correct': true});
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    
    if (result != null && result['correct'] == true) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Correct! Reviewing...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh cards after submission
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {});
      });
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64),
            const SizedBox(height: 16),
            const Text('User Profile'),
          ],
        ),
      ),
    );
  }
}

// Services (moved to separate files)
