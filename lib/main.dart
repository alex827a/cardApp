import 'package:flutter/material.dart';
import 'app.dart';
import 'hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupHive();
  
  runApp(MyApp());
}
