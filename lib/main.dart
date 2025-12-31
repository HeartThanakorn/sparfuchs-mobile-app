import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/camera_screen.dart';
import 'package:sparfuchs_ai/firebase_options.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
              '🦊 Tap the camera to scan a receipt!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          // Navigate to Camera Screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bild erfolgreich aufgenommen! 📸'),
              ),
            );
          }
        },
        child: const Icon(Icons.camera_alt, size: 32),
      ),
    );
  }
}
