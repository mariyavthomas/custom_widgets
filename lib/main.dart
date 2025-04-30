import 'package:flutter/material.dart';
import 'package:flutterintern/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicinePage(),
    );
  }
}
