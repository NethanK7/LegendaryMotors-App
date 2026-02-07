import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../shared/models/car.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'legendary_motors.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Cars Table (Inventory)
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY,
        model TEXT,
        brand TEXT,
        price INTEGER,
        year INTEGER,
        imageUrl TEXT,
        category TEXT,
        status TEXT,
        specs TEXT -- Stored as JSON string
      )
    ''');

    // 2. Allocations Table (My Garage)
    await db.execute('''
      CREATE TABLE allocations(
        id INTEGER PRIMARY KEY,
        model TEXT,
        brand TEXT,
        price INTEGER,
        year INTEGER,
        imageUrl TEXT,
        category TEXT,
        status TEXT,
        specs TEXT,
        allocated_at TEXT
      )
    ''');

    // 3. Settings Table (Local App Settings)
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE cars ADD COLUMN year INTEGER');
      await db.execute('ALTER TABLE allocations ADD COLUMN year INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE settings(
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
  }

  // --- Start of CRUD Operations for Cars (Fleet) ---

  Future<void> cacheCars(List<Car> cars) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('cars'); // Clear old cache
      for (final car in cars) {
        await txn.insert(
          'cars',
          car.toJsonForDb(), // Helper method we will add
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertCar(Car car) async {
    final db = await database;
    await db.insert(
      'cars',
      car.toJsonForDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCar(Car car) async {
    final db = await database;
    await db.update(
      'cars',
      car.toJsonForDb(),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  Future<void> deleteCar(int id) async {
    final db = await database;
    await db.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Car>> getCachedCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cars');

    return List.generate(maps.length, (i) {
      return Car.fromJsonFromDb(maps[i]); // Helper method we will add
    });
  }

  // --- Start of CRUD Operations for Allocations (Garage) ---

  Future<void> cacheAllocations(List<Car> cars) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('allocations'); // Clear old cache
      for (final car in cars) {
        final data = car.toJsonForDb();
        data['allocated_at'] = DateTime.now()
            .toIso8601String(); // Add timestamp if needed
        await txn.insert(
          'allocations',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Car>> getCachedAllocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('allocations');

    return List.generate(maps.length, (i) {
      return Car.fromJsonFromDb(maps[i]);
    });
  }

  // --- Start of Settings Operations ---

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }
}
