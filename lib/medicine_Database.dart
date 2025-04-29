// medicine_db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MedicineEntry {
  int? id;
  String name;
  DateTime addedOn;
  bool isKept;
  bool isMarkedForRemoval;
  bool isNew;
  DateTime? markedRemovalTime;
  bool showKeepRemoveAlways;
  DateTime? lastKeptOrRemovedDate;
  String? status;

  MedicineEntry({
    this.id,
    required this.name,
    required this.addedOn,
    this.isKept = false,
    this.isMarkedForRemoval = false,
    this.isNew = true,
    this.markedRemovalTime,
    this.showKeepRemoveAlways = false,
    this.lastKeptOrRemovedDate,
    this.status = 'Not Reviewed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': addedOn.toIso8601String(),
      'status': status,
      'isKept': isKept ? 1 : 0,
      'isMarkedForRemoval': isMarkedForRemoval ? 1 : 0,
      'isNew': isNew ? 1 : 0,
      'showKeepRemoveAlways': showKeepRemoveAlways ? 1 : 0,
      'markedRemovalTime': markedRemovalTime?.toIso8601String(),
      'lastKeptOrRemovedDate': lastKeptOrRemovedDate?.toIso8601String(),
    };
  }

  static MedicineEntry fromMap(Map<String, dynamic> map) {
    return MedicineEntry(
      id: map['id'],
      name: map['name'],
      addedOn: DateTime.parse(map['date']),
      status: map['status'],
      isKept: map['isKept'] == 1,
      isMarkedForRemoval: map['isMarkedForRemoval'] == 1,
      isNew: map['isNew'] == 1,
      showKeepRemoveAlways: map['showKeepRemoveAlways'] == 1,
      markedRemovalTime: map['markedRemovalTime'] != null
          ? DateTime.parse(map['markedRemovalTime'])
          : null,
      lastKeptOrRemovedDate: map['lastKeptOrRemovedDate'] != null
          ? DateTime.parse(map['lastKeptOrRemovedDate'])
          : null,
    );
  }
}

class MedicineDBHelper {
  static final MedicineDBHelper _instance = MedicineDBHelper._();
  static Database? _db;

  MedicineDBHelper._();

  factory MedicineDBHelper() => _instance;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'medicine.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            date TEXT,
            status TEXT,
            isKept INTEGER,
            isMarkedForRemoval INTEGER,
            isNew INTEGER,
            showKeepRemoveAlways INTEGER,
            markedRemovalTime TEXT,
            lastKeptOrRemovedDate TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertMedicine(MedicineEntry medicine) async {
    final dbClient = await db;
    await dbClient.insert(
      'medicines',
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MedicineEntry>> getMedicinesByDate(DateTime date) async {
    final dbClient = await db;
    final formattedDate =
        date.toIso8601String().split('T')[0]; // match only by date
    final result = await dbClient.query(
      'medicines',
      where: 'date LIKE ?',
      whereArgs: ['$formattedDate%'],
    );
    return result.map((e) => MedicineEntry.fromMap(e)).toList();
  }

  Future<void> updateMedicine(MedicineEntry medicine) async {
    final dbClient = await db;
    await dbClient.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<void> deleteMedicinesByDate(DateTime date) async {
    final dbClient = await db;
    final formattedDate = date.toIso8601String().split('T')[0];
    await dbClient.delete(
      'medicines',
      where: 'date LIKE ?',
      whereArgs: ['$formattedDate%'],
    );
  }
 Future<void> updateDate(DateTime date) async {
  final dbClient = await db; // Ensure db is awaited to get the Database instance

  // Update the 'date' field in the database where the date matches
  await dbClient.update(
    'medicines',
    {'date': date.toIso8601String()}, // Update the date field
    where: 'date = ?',
    whereArgs: [date.toIso8601String()],
  );
}

}
