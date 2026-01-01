import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Settings screen - SIMPLIFIED with only working features
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: const Color(AppColors.primaryTeal),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _buildSectionTitle('APPEARANCE'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(AppColors.primaryTeal),
              ),
              title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(isDarkMode ? 'Dark' : 'Light'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = 
                      value ? ThemeMode.dark : ThemeMode.light;
                },
                activeColor: const Color(AppColors.primaryTeal),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Data Section
          _buildSectionTitle('DATA'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // Data Size (info only, no arrow)
                ListTile(
                  leading: const Icon(Icons.storage_outlined, color: Color(AppColors.primaryTeal)),
                  title: const Text('Data Size', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(_getDataSize()),
                  // No trailing = no arrow
                ),
                const Divider(height: 1),
                // Clear All Data (has action)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(AppColors.errorRed)),
                  title: const Text(
                    'Clear All Data', 
                    style: TextStyle(fontWeight: FontWeight.w500, color: Color(AppColors.errorRed)),
                  ),
                  subtitle: Text('Delete all receipts permanently', style: TextStyle(color: Colors.grey.shade600)),
                  onTap: () => _showClearDataDialog(context, ref),
                  // No arrow - action is in onTap
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section - Info Only
          _buildSectionTitle('ABOUT'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: Color(AppColors.primaryTeal)),
                  title: Text('Version', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.smart_toy_outlined, color: Color(AppColors.primaryTeal)),
                  title: Text('AI Engine', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Gemini 2.5 Flash'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code, color: Color(AppColors.primaryTeal)),
                  title: Text('Built with', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Flutter & Riverpod'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(AppColors.neutralGray),
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _getDataSize() {
    try {
      final box = LocalDatabaseService.receiptsBox;
      final count = box.keys.length;
      return '$count receipts stored';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(AppColors.errorRed)),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all receipts and cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.errorRed),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      final box = LocalDatabaseService.receiptsBox;
      final count = box.keys.length;
      
      await box.clear();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $count receipts successfully'),
            backgroundColor: const Color(AppColors.successGreen),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
        );
      }
    }
  }
}
