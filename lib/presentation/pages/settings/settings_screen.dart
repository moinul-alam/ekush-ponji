// lib/presentation/pages/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/services/settings_service.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settingsService;
  AppSettings? _currentSettings;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _currentSettings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        if (_currentSettings == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(_getLocalizedText('Settings')),
                floating: true,
                automaticallyImplyLeading: false,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0), // Using hardcoded value
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildLanguageSection(appState),
                    const SizedBox(height: 16.0),
                    _buildThemeSection(appState),
                    const SizedBox(height: 16.0),
                    _buildNotificationSection(),
                    const SizedBox(height: 16.0),
                    _buildAboutSection(),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection(AppStateManager appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedText('Language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            RadioListTile<String>(
              title: const Text('বাংলা'),
              value: 'bn',
              groupValue: appState.locale.languageCode,
              onChanged: (value) => _changeLocale(
                appState, 
                const Locale('bn', 'BD')
              ),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: appState.locale.languageCode,
              onChanged: (value) => _changeLocale(
                appState, 
                const Locale('en', 'US')
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(AppStateManager appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedText('Theme'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            RadioListTile<ThemeMode>(
              title: Text(_getLocalizedText('Light Mode')),
              value: ThemeMode.light,
              groupValue: appState.themeMode,
              onChanged: (value) => _changeTheme(appState, value),
            ),
            RadioListTile<ThemeMode>(
              title: Text(_getLocalizedText('Dark Mode')),
              value: ThemeMode.dark,
              groupValue: appState.themeMode,
              onChanged: (value) => _changeTheme(appState, value),
            ),
            RadioListTile<ThemeMode>(
              title: Text(_getLocalizedText('System Default')),
              value: ThemeMode.system,
              groupValue: appState.themeMode,
              onChanged: (value) => _changeTheme(appState, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedText('Notifications'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            SwitchListTile(
              title: Text(_getLocalizedText('Enable Notifications')),
              value: _currentSettings!.notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SwitchListTile(
              title: Text(_getLocalizedText('Enable Sound')),
              value: _currentSettings!.soundEnabled,
              onChanged: _currentSettings!.notificationsEnabled 
                  ? _toggleSound 
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedText('About'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            ListTile(
              title: Text(_getLocalizedText('App Version')),
              subtitle: const Text('1.0.0'), // Hardcoded for now
              leading: const Icon(Icons.info_outline),
              onTap: _showVersionDialog,
            ),
            ListTile(
              title: Text(_getLocalizedText('Licenses')),
              leading: const Icon(Icons.assignment),
              onTap: () => showLicensePage(context: context),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLocale(AppStateManager appState, Locale locale) async {
    // Update through Provider
    await appState.updateLocale(locale);
    
    // Also update local settings
    await _settingsService.saveLocale(locale);
    setState(() {
      _currentSettings = _currentSettings!.copyWith(locale: locale);
    });
  }

  void _changeTheme(AppStateManager appState, ThemeMode? themeMode) async {
    if (themeMode != null) {
      // Update through Provider
      await appState.updateTheme(themeMode);
      
      // Also update local settings
      await _settingsService.saveThemeMode(themeMode);
      setState(() {
        _currentSettings = _currentSettings!.copyWith(themeMode: themeMode);
      });
    }
  }

  void _toggleNotifications(bool value) async {
    await _settingsService.saveNotificationsEnabled(value);
    setState(() {
      _currentSettings = _currentSettings!.copyWith(
        notificationsEnabled: value,
        soundEnabled: value ? _currentSettings!.soundEnabled : false,
      );
    });
  }

  void _toggleSound(bool value) async {
    await _settingsService.saveSoundEnabled(value);
    setState(() {
      _currentSettings = _currentSettings!.copyWith(soundEnabled: value);
    });
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getLocalizedText('App Version')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_getLocalizedText('Version')}: 1.0.0'),
              const SizedBox(height: 8),
              Text('${_getLocalizedText('App Name')}: Ekush Ponji'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getLocalizedText('OK')),
            ),
          ],
        );
      },
    );
  }

  String _getLocalizedText(String key) {
    final appState = context.watch<AppStateManager>();
    final isBengali = appState.locale.languageCode == 'bn';
    
    switch (key) {
      case 'Settings': return isBengali ? 'সেটিংস' : 'Settings';
      case 'Language': return isBengali ? 'ভাষা' : 'Language';
      case 'Theme': return isBengali ? 'থিম' : 'Theme';
      case 'Light Mode': return isBengali ? 'লাইট মোড' : 'Light Mode';
      case 'Dark Mode': return isBengali ? 'ডার্ক মোড' : 'Dark Mode';
      case 'System Default': return isBengali ? 'সিস্টেম ডিফল্ট' : 'System Default';
      case 'Notifications': return isBengali ? 'বিজ্ঞপ্তি' : 'Notifications';
      case 'Enable Notifications': return isBengali ? 'বিজ্ঞপ্তি সক্রিয়' : 'Enable Notifications';
      case 'Enable Sound': return isBengali ? 'সাউন্ড সক্রিয়' : 'Enable Sound';
      case 'About': return isBengali ? 'সম্পর্কে' : 'About';
      case 'App Version': return isBengali ? 'অ্যাপ সংস্করণ' : 'App Version';
      case 'Licenses': return isBengali ? 'লাইসেন্স' : 'Licenses';
      case 'Version': return isBengali ? 'সংস্করণ' : 'Version';
      case 'App Name': return isBengali ? 'অ্যাপের নাম' : 'App Name';
      case 'OK': return isBengali ? 'ঠিক আছে' : 'OK';
      default: return key;
    }
  }
}
