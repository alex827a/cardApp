// lib/main.dart

import 'package:flutter/material.dart';
import 'app.dart';
import 'hive_setup.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    try {
    await setupHive();
  } catch (e) {
    print('Error initializing Hive: $e');
    // You might want to show an error dialog here
  }

  runApp(MyApp());
}
