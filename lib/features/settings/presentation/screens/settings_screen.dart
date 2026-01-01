import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Settings screen with working features
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
          // App Section
          _SettingsSection(
            title: 'APP',
            children: [
              _SettingsTile(
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'Theme',
                subtitle: isDarkMode ? 'Dark' : 'Light',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state = 
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                  activeColor: const Color(AppColors.primaryTeal),
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = 
                      isDarkMode ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Data Section
          _SettingsSection(
            title: 'DATA',
            children: [
              _SettingsTile(
                icon: Icons.folder_outlined,
                title: 'Storage',
                subtitle: 'Local Device (Hive)',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: 'Data Size',
                subtitle: _getDataSize(),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Data',
                subtitle: 'Delete all receipts permanently',
                onTap: () => _showClearDataDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // About Section
          _SettingsSection(
            title: 'ABOUT',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.smart_toy_outlined,
                title: 'AI Engine',
                subtitle: 'Gemini 2.5 Flash',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.code,
                title: 'Built with',
                subtitle: 'Flutter & Riverpod',
                onTap: () {},
              ),
            ],
          ),
        ],
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.neutralGray),
              letterSpacing: 1,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? const Color(AppColors.errorRed)
            : const Color(AppColors.primaryTeal),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive 
              ? const Color(AppColors.errorRed) 
              : const Color(AppColors.darkNavy),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
