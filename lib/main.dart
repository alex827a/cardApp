import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'locale_provider.dart';
import 'hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupHive();
  
  runApp(MyApp());
}
