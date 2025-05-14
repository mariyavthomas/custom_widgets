import 'package:flutterintern/medicineTile.dart'; // Adjust the path as needed
import 'package:flutterintern/medicine_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MedicineDBHelper {
  static final MedicineDBHelper _instance = MedicineDBHelper._();
  static Database? _db;

  MedicineDBHelper._();

  factory MedicineDBHelper() => _instance;

  // Get the database instance (create if not already done)
  Future<Database> get db async {
    if (_db != null) return _db!; // If db already exists, return it
    _db = await initDB(); // Initialize DB if it doesn't exist
    return _db!;
  }

  // Initialize the database
  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'medicineslist.db');
    return openDatabase(
      path,
      version: 2,  // Increment the version to trigger onUpgrade
      onCreate: (db, version) async {
        // Create the 'medicines' table when DB is first created
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
            lastKeptOrRemovedDate TEXT,
            dosage TEXT,
            dosageTimes TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Ensure that the new column `addedOn` is added in case of upgrade
        if (oldVersion < newVersion) {
          // Add the `addedOn` column if it doesn't exist
          // await db.execute('ALTER TABLE medicines ADD COLUMN addedOn TEXT');
          
          // // Backfill existing records with default value for the `addedOn` column
          // await db.execute('UPDATE medicines SET addedOn = ? WHERE addedOn IS NULL', ['2025-01-01']);
        }
      },
    );
  }

  // Insert a medicine entry into the database
  Future<void> insertMedicine(MedicineEntry medicine) async {
    final dbClient = await db;
    await dbClient.insert(
      'medicines',
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace any existing record with the same ID
    );
  }

  // Fetch all medicines and group them by date
  Future<Map<String, List<MedicineEntry>>> getAllMedicinesGroupedByDate() async {
    final dbClient = await db;
    final result = await dbClient.query('medicines');

    List<MedicineEntry> entries = result.map((e) => MedicineEntry.fromMap(e)).toList();

    Map<String, List<MedicineEntry>> groupedEntries = {};

    for (var entry in entries) {
      String dateKey = entry.addedOn.toIso8601String().split('T')[0]; // Extract only the date part (YYYY-MM-DD)

      // Add entry to the appropriate date group
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }

    return groupedEntries;
  }
Future<void> printAllMedicines() async {
  final dbClient = await db;
  final result = await dbClient.query('medicines'); // Get all rows from the medicines table
  
  // Loop through the result and print each row
  for (var row in result) {
    print('ID: ${row['id']}');
    print('Name: ${row['name']}');
    print('Date: ${row['date']}');
    print('Status: ${row['status']}');
    print('isKept: ${row['isKept']}');
    print('isMarkedForRemoval: ${row['isMarkedForRemoval']}');
    print('isNew: ${row['isNew']}');
    print('showKeepRemoveAlways: ${row['showKeepRemoveAlways']}');
    print('markedRemovalTime: ${row['markedRemovalTime']}');
    print('lastKeptOrRemovedDate: ${row['lastKeptOrRemovedDate']}');
    print('---');
  }
}

  // Get medicines for a specific date
  Future<List<MedicineEntry>> getMedicinesForDate(String date) async {
    final dbClient = await db;
    // Get the current date in the format YYYY-MM-DD
  String currentDate = DateTime.now().toIso8601String().split('T')[0];
    final result = await dbClient.query(
      'medicines',
      where: 'Date LIKE ?',
      whereArgs: ['$date%'], // Matches all entries for that date
    );
   // print('Result: $result');

    return result.map((e) => MedicineEntry.fromMap(e)).toList();
  }

  // Update a medicine entry in the database
  Future<void> updateMedicine(MedicineEntry medicine) async {
    final dbClient = await db;
    await dbClient.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  // Delete medicines by a specific date
  Future<void> deleteMedicineIfOneDayPassed(int id) async {
    final dbClient = await db;

    // Fetch the medicine entry
    final List<Map<String, dynamic>> result = await dbClient.query(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      // Assuming you have a 'date' column stored as a string (example: '2025-04-27')
      String dateString = result.first['date']; 

      DateTime medicineDate = DateTime.parse(dateString);
      DateTime currentDate = DateTime.now();

      // Check if at least 1 day has passed
      if (currentDate.isAfter(medicineDate.add(Duration(days: 1)))) {
        await dbClient.delete('medicines', where: 'id = ?', whereArgs: [id]);
        print('Medicine deleted because 1 day passed.');
      } else {
        print('1 day has not yet passed. Not deleting.');
      }
    } else {
      print('Medicine not found.');
    }
  }

  // Update the 'date' field for medicines matching the specific date
  Future<void> updateDate(DateTime date) async {
    final dbClient = await db;
    await dbClient.update(
      'medicines',
      {'date': date.toIso8601String()}, // Update the date to the new date
      where: 'date = ?',
      whereArgs: [date.toIso8601String()], // Target the old date to update
    );
  }
}
