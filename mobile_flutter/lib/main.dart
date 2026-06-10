import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
  ]);
  
  // Request necessary permissions
  _requestPermissions();
}

Future<void> _requestPermissions() async {
  if (io.Platform.isAndroid) {
    // Request SYSTEM_ALERT_WINDOW permission for overlay
    // This needs to be declared in AndroidManifest.xml
  } else if (io.Platform.isIOS) {
    // Request notification and background fetch permissions
    // These are handled via Info.plist
  }
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
      ),
      home: const ZombieOverlayScreen(),
    );
  }
}

class ZombieOverlayScreen extends StatefulWidget {
  const ZombieOverlayScreen({super.key});

  @override
  State<ZombieOverlayScreen> createState() => _ZombieOverlayScreenState();
}

class _ZombieOverlayScreenState extends State<ZombieOverlayScreen> {
  int _currentIndex = 0;
  
  // Learning cards for display
  final List<Map<String, dynamic>> _learningCards = [
    {
      'expression': 'Take it easy',
      'meaning': '진정해, 서두르지 마',
      'example1': 'Take it easy! We still have plenty of time.',
      'example2': '진정해! 우리 아직 시간 많이 남아있어.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    // Initialize SQLite database with SQLCipher
    try {
      await openDatabase(
        'naya.db',
        version: (1, 0),
        onCreate: (db, version) async {
          // Create tables as defined in DATABASE_SCHEMA.md
          await db.execute('''
            CREATE TABLE user_profiles (
              user_id TEXT PRIMARY KEY,
              user_name TEXT NOT NULL,
              wakeup_time TEXT DEFAULT '07:00',
              sleep_time TEXT DEFAULT '23:00',
              preferred_voice TEXT DEFAULT 'lover',
              stress_threshold INTEGER DEFAULT 75
            )
          ''');
        },
      );
    } catch (e) {
      print('Database initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Learning Overlay Screen
          _buildLearningOverlay(),
          
          // Quiz Submit Screen
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Evening Quiz', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                Text('Submit your answers here'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningOverlay() {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        
        // Learning card content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🦴 Zombie Card',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                
                // Learning card widget
                if (_learningCards.isNotEmpty)
                  _buildLearningCard(_learningCards[0]),
                
                SizedBox(height: 48),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to quiz screen
                        setState(() => _currentIndex = 1);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Start Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Close button (disabled during Teenager Locker mode)
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Implement annoyance cap logic here
              // Disable after 2 consecutive closes within 4 hours
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLearningCard(Map<String, dynamic> card) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card['expression'] as String,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Icon(Icons.ear, size: 32, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '[${card['pronunciation'] ?? ''}]',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            Text(
              card['meaning'] as String,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            
            // Example sentences
            _buildExampleCard('EN', card['example1'] as String?),
            _buildExampleCard('KO', card['example2'] as String?),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String lang, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(lang, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
