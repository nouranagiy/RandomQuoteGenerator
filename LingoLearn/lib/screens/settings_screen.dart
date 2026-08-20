import 'package:flutter/material.dart';
import '../services/language_storage.dart';
class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });
  Future<void> _resetData(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset App Data',
            style: TextStyle(fontWeight: FontWeight.bold,),
          ),
          content: Text(
            'This will delete your added words, '
                'favorites, learned progress, and quiz results. '
                'Default words will be restored.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
    if (shouldReset != true) return;
    final storage = LanguageStorage();
    await storage.resetAllData();
    await storage.initializeDefaultWords();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('App data has been reset successfully.',),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: isDarkMode,
              onChanged: (_) {
                onToggleTheme();
              },
              secondary: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
              title: Text('Dark Mode',),
              subtitle: Text(
                isDarkMode ? 'Dark theme is enabled' : 'Light theme is enabled',
              ),
            ),
          ),
          SizedBox(height: 30),
          Text('Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(Icons.restart_alt_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text('Reset App Data',),
              subtitle: Text('Delete your progress and restore default words',),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
              onTap: () {
                _resetData(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}