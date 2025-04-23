import 'package:flutter/material.dart';
import 'package:flutterintern/home.dart';
import 'package:flutterintern/medicineTile.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // Hive.registerAdapter(MedicineEntryAdapter());
  // await Hive.openBox<MedicineEntry>('medicines');
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MedicinePage(),
    );
  }
}
