import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'route_tracking.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Routes table
    await db.execute('''
      CREATE TABLE routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT,
        end_time TEXT,
        status TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Route points table
    await db.execute('''
      CREATE TABLE route_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER,
        latitude REAL,
        longitude REAL,
        timestamp TEXT,
        speed REAL,
        accuracy REAL,
        FOREIGN KEY (route_id) REFERENCES routes (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD Operations for Routes ---

  Future<int> startNewRoute() async {
    final db = await database;
    return await db.insert('routes', {
      'start_time': DateTime.now().toIso8601String(),
      'status': 'active',
      'is_synced': 0,
    });
  }

  Future<void> endRoute(int routeId) async {
    final db = await database;
    await db.update(
      'routes',
      {
        'end_time': DateTime.now().toIso8601String(),
        'status': 'completed',
      },
      where: 'id = ?',
      whereArgs: [routeId],
    );
  }

  Future<int> insertPoint(Map<String, dynamic> pointData) async {
    final db = await database;
    return await db.insert('route_points', pointData);
  }

  Future<List<Map<String, dynamic>>> getActiveRoutes() async {
    final db = await database;
    return await db.query('routes', where: 'status = ?', whereArgs: ['active']);
  }

  Future<List<Map<String, dynamic>>> getAllRoutes() async {
    final db = await database;
    return await db.query('routes', orderBy: 'start_time DESC');
  }

  Future<List<Map<String, dynamic>>> getPointsForRoute(int routeId) async {
    final db = await database;
    return await db.query('route_points',
        where: 'route_id = ?', whereArgs: [routeId], orderBy: 'timestamp ASC');
  }

  Future<void> markAsSynced(int routeId) async {
    final db = await database;
    await db.update('routes', {'is_synced': 1},
        where: 'id = ?', whereArgs: [routeId]);
  }

  Future<void> deleteRoute(int routeId) async {
    final db = await database;
    await db.delete('routes', where: 'id = ?', whereArgs: [routeId]);
  }
}
