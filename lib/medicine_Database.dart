import 'package:flutterintern/medicine.entry.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Create this model based on your MedicineEntry class

class MedicineDatabase {
  static final MedicineDatabase instance = MedicineDatabase._init();
  static Database? _database;

  MedicineDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicines.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE medicines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      addedOn TEXT,
      isNew INTEGER,
      isKept INTEGER,
      isMarkedForRemoval INTEGER,
      showKeepRemoveAlways INTEGER,
      markedRemovalTime TEXT,
      lastKeptOrRemovedDate TEXT,
      status TEXT
    )
    ''');
  }

  Future<int> createMedicine(MedicineEntry medicine) async {
    final db = await instance.database;
    return await db.insert('medicines', medicine.toJson());
  }

  Future<List<MedicineEntry>> readMedicinesByDate(DateTime date) async {
    final db = await instance.database;
    final key = DateFormat('yyyy-MM-dd').format(date);

    final result = await db.query(
      'medicines',
      where: "addedOn = ?",
      whereArgs: [key],
    );

    return result.map((json) => MedicineEntry.fromJson(json)).toList();
  }

  Future<int> updateMedicine(MedicineEntry medicine) async {
    final db = await instance.database;
    return await db.update(
      'medicines',
      medicine.toJson(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await instance.database;
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
