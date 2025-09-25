import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;

  const SettingsScreen({
    Key? key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  }) : super(key: key);

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
            title: Text(LocalizationHelper.getSettings(context)),
            floating: true,
            automaticallyImplyLeading: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildLanguageSection(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildThemeSection(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildNotificationSection(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildAboutSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.isBengali(context) ? 'ভাষা' : 'Language',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            RadioListTile<String>(
              title: const Text('বাংলা'),
              value: 'bn',
              groupValue: _currentSettings!.locale.languageCode,
              onChanged: (value) => _changeLocale(const Locale('bn', 'BD')),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _currentSettings!.locale.languageCode,
              onChanged: (value) => _changeLocale(const Locale('en', 'US')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.isBengali(context) ? 'থিম' : 'Theme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            RadioListTile<ThemeMode>(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'লাইট মোড' 
                  : 'Light Mode'),
              value: ThemeMode.light,
              groupValue: _currentSettings!.themeMode,
              onChanged: _changeTheme,
            ),
            RadioListTile<ThemeMode>(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'ডার্ক মোড' 
                  : 'Dark Mode'),
              value: ThemeMode.dark,
              groupValue: _currentSettings!.themeMode,
              onChanged: _changeTheme,
            ),
            RadioListTile<ThemeMode>(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'সিস্টেম ডিফল্ট' 
                  : 'System Default'),
              value: ThemeMode.system,
              groupValue: _currentSettings!.themeMode,
              onChanged: _changeTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.isBengali(context) 
                  ? 'বিজ্ঞপ্তি' 
                  : 'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            SwitchListTile(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'বিজ্ঞপ্তি সক্রিয়' 
                  : 'Enable Notifications'),
              value: _currentSettings!.notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SwitchListTile(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'সাউন্ড সক্রিয়' 
                  : 'Enable Sound'),
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
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.isBengali(context) ? 'সম্পর্কে' : 'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ListTile(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'অ্যাপ সংস্করণ' 
                  : 'App Version'),
              subtitle: Text(AppConstants.appVersion),
              leading: const Icon(Icons.info_outline),
              onTap: _showVersionDialog,
            ),
            ListTile(
              title: Text(LocalizationHelper.isBengali(context) 
                  ? 'লাইসেন্স' 
                  : 'Licenses'),
              leading: const Icon(Icons.assignment),
              onTap: () => showLicensePage(context: context),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLocale(Locale locale) async {
    widget.onLocaleChanged(locale);
    await _settingsService.saveLocale(locale);
    setState(() {
      _currentSettings = _currentSettings!.copyWith(locale: locale);
    });
  }

  void _changeTheme(ThemeMode? themeMode) async {
    if (themeMode != null) {
      widget.onThemeChanged(themeMode);
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
          title: Text(LocalizationHelper.isBengali(context) 
              ? 'অ্যাপ সংস্করণ' 
              : 'App Version'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${LocalizationHelper.isBengali(context) ? 'সংস্করণ' : 'Version'}: ${AppConstants.appVersion}'),
              const SizedBox(height: 8),
              Text('${LocalizationHelper.isBengali(context) ? 'অ্যাপের নাম' : 'App Name'}: ${AppConstants.appName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocalizationHelper.isBengali(context) ? 'ঠিক আছে' : 'OK'),
            ),
          ],
        );
      },
    );
  }
}