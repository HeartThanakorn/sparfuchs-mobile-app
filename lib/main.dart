import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // TODO: Add localization
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}

/// Temporary Home Screen - will be replaced with proper navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SparFuchs AI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: AppTheme.primaryTeal,
            ),
            const SizedBox(height: 24),
            Text(
              'SparFuchs AI',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Receipt Scanner & Expense Tracker',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            Text(
              '🦊 Coming Soon!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          // TODO: Navigate to Camera Screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera scanning coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.camera_alt, size: 32),
      ),
    );
  }
}
