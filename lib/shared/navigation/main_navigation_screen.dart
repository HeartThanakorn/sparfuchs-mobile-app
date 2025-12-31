import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/receipt_archive_screen.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/camera_screen.dart';
import 'package:sparfuchs_ai/features/settings/presentation/screens/settings_screen.dart';

/// Main navigation screen with Bottom Tab Bar
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ReceiptArchiveScreen(),
    _CameraPlaceholder(), // Will navigate to CameraScreen
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              // Camera tab - navigate to Camera Screen
              _openCamera();
            } else {
              setState(() => _currentIndex = index);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Archive',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          indicatorColor: const Color(AppColors.primaryTeal).withValues(alpha: 0.2),
          backgroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black26,
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    
    if (result == true && mounted) {
      // Receipt saved successfully, switch to Archive tab
      setState(() => _currentIndex = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt saved! 📸'),
          backgroundColor: Color(AppColors.successGreen),
        ),
      );
    }
  }
}

/// Placeholder widget for the camera tab (never actually displayed)
class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
