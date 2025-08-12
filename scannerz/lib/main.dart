import 'package:flutter/material.dart';
import 'screens/scan/scan_screen.dart';

void main() {
  runApp(const ScannerzApp());
}

class ScannerzApp extends StatelessWidget {
  const ScannerzApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scannerz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const ScanScreen(),
    );
  }
}