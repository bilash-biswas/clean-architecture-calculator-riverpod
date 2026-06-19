import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/core/services/database_service.dart';
import 'package:calculator/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbService = DatabaseService();
  await dbService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
