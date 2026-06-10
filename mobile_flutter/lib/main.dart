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
            return Center(child: const Text('No cards available'));
          }
          
          final cards = snapshot.data!;
          
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(card['expression'] ?? ''),
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
    // TODO: Implement answer submission with SM-2 algorithm
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reviewing...')),
    );
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

// Services
class BleService {
  static final BleService _instance = BleService._();
  
  factory BleService() => _instance;
  
  bool _isConnected = false;
  
  Future<void> start() async {
    print('Starting BLE controller...');
    // Implementation using flutter_blue_plus
  }
  
  static Future<void> disconnectFromDevice() async {
    print('Disconnecting from BLE device');
  }
}

class LearningService {
  final String _baseUrl = 'https://api.naya.app/api/v1';
  
  Future<List<Map<String, dynamic>>> getZombieCards() async {
    try {
      // Fetch zombie cards from backend API
      return []; // Placeholder - implement with http package
    } catch (e) {
      print('Error fetching zombie cards: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> submitQuiz(String cardId, int answerIndex) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/learning/quiz/submit'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        body: jsonEncode({
          'cardId': cardId,
          'answerIndex': answerIndex,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error submitting quiz: $e');
    }
    
    return {'success': false};
  }
}

// Models
class CardModel {
  final String id;
  final String expression;
  final String meaning;
  
  CardModel({required this.id, required this.expression, required this.meaning});
}
