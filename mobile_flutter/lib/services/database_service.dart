import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  
  factory DatabaseService() => _instance;
  
  Database? _database;
  
  Future<void> initDatabase() async {
    try {
      // Use different database path for iOS and Android
      String dbPath;
      
      if (io.Platform.isIOS) {
        dbPath = await getDatabasesPath();
      } else {
        dbPath = await getApplicationDocumentsDirectory().path;
      }
      
      _database = await openDatabase(
        'naya.db',
        path: '$dbPath/naya.db',
        version: 1,
        onCreate: (db, version) async {
          // Create tables as defined in DATABASE_SCHEMA.md
          await db.execute('''
            CREATE TABLE users (
              id TEXT PRIMARY KEY,
              username TEXT NOT NULL,
              password_hash TEXT NOT NULL,
              voice_preference TEXT DEFAULT 'eleven_labs',
              stress_threshold INTEGER DEFAULT 75,
              wakeup_time TEXT,
              sleep_time TEXT,
              reps INTEGER DEFAULT 0,
              interval_days INTEGER DEFAULT 1,
              ef REAL DEFAULT 1.3,
              last_active DATETIME DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          
          await db.execute('''
            CREATE TABLE learning_cards (
              id TEXT PRIMARY KEY,
              question TEXT NOT NULL,
              options TEXT NOT NULL,
              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
              reviewed_at DATETIME
            )
          ''');
          
          print('Database initialized successfully');
        },
      );
      
      // Insert default user if not exists
      await _ensureDefaultUser();
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
  
  Future<void> _ensureDefaultUser() async {
    try {
      final result = await _database?.rawInsert(
        'INSERT OR IGNORE INTO users (id, username, password_hash) VALUES (?, ?, ?)',
        ['default_user', 'demo_user', 'hashed_password'],
      );
      
      print('Default user ensured: $result');
    } catch (e) {
      print('Error ensuring default user: $e');
    }
  }
  
  Future<void> insertCard(Map<String, dynamic> card) async {
    try {
      await _database?.insert('learning_cards', card);
    } catch (e) {
      print('Error inserting card: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getCards() async {
    try {
      final result = await _database?.query('learning_cards', orderBy: 'created_at DESC') ?? [];
      return result;
    } catch (e) {
      print('Error getting cards: $e');
      return [];
    }
  }
  
  Future<void> close() async {
    try {
      await _database?.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
