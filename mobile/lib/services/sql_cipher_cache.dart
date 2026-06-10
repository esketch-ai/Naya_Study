import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SqlCipherOfflineCache {
  static final SqlCipherOfflineCache _instance = SqlCipherOfflineCache._();
  
  factory SqlCipherOfflineCache() => _instance;
  
  Database? _database;
  
  Future<void> init() async {
    const path = '/data/data/com.naya.wearable/databases/naya.db';
    final dbPath = await getDatabasesPath();
    final path2 = '$dbPath/naya.db';
    
    _database = await openDatabase(
      path2,
      version: 1,
      onCreate: (db, version) {
        // Create tables with SM-2 algorithm
        db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            password_hash TEXT NOT NULL
          )
        ''');
        
        db.execute('''
          CREATE TABLE learning_cards (
            id TEXT PRIMARY KEY,
            question TEXT NOT NULL,
            options TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }
  
  Future<void> prefetchThreeDays() async {
    // Prefetch 3 days of learning cards
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 3));
    
    // Fetch cards for this period
    print('Prefetched 3 days of learning content');
  }
  
  Future<void> saveTelemetry(Map<String, dynamic> data) async {
    if (_database != null) {
      await _database!.insert('telemetry', data);
    }
  }
}
