import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/service_request.dart';
import '../../models/wallet_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yegna_connect_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_requests (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        customerImage TEXT,
        providerId TEXT NOT NULL,
        providerName TEXT NOT NULL,
        providerImage TEXT,
        categoryId TEXT NOT NULL,
        serviceTitle TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        scheduledAt TEXT NOT NULL,
        isUnlockedByProvider INTEGER NOT NULL,
        unlockCreditCost INTEGER NOT NULL,
        syncToken TEXT UNIQUE NOT NULL,
        isSyncedOffline INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wallet_transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        creditsAmount INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        referenceNumber TEXT,
        paymentMethod TEXT,
        balanceAfter INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertOfflineRequest(ServiceRequest request) async {
    final db = await instance.database;
    return await db.insert(
      'offline_requests',
      request.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ServiceRequest>> getOfflineRequests() async {
    final db = await instance.database;
    final maps = await db.query('offline_requests', orderBy: 'createdAt DESC');
    return maps.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  Future<int> deleteOfflineRequest(String syncToken) async {
    final db = await instance.database;
    return await db.delete(
      'offline_requests',
      where: 'syncToken = ?',
      whereArgs: [syncToken],
    );
  }

  Future<int> insertWalletTransaction(CreditTransaction transaction) async {
    final db = await instance.database;
    return await db.insert(
      'wallet_transactions',
      transaction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CreditTransaction>> getWalletTransactions() async {
    final db = await instance.database;
    final maps = await db.query('wallet_transactions', orderBy: 'timestamp DESC');
    return maps.map((json) => CreditTransaction.fromJson(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
