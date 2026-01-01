import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';
import 'package:sparfuchs_ai/shared/navigation/main_navigation_screen.dart';
import 'package:sparfuchs_ai/firebase_options.dart';
import 'package:sparfuchs_ai/core/config/api_key_config.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables (loads .env for Gemini API key)
  await ApiKeyConfig.initialize();

  // Initialize Local Database (Hive)
  await LocalDatabaseService.initialize();

  // Initialize locale data for DateFormat (English)
  await initializeDateFormatting('en_US', null);

  // Initialize Firebase (minimal - for potential analytics, optional)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: SparFuchsApp(),
    ),
  );
}

/// SparFuchs AI - Smart Receipt Scanner & Expense Tracker
class SparFuchsApp extends StatelessWidget {
  const SparFuchsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SparFuchs AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
