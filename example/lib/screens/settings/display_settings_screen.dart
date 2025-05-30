import 'package:flutter/material.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  String _selectedTheme = 'system';
  String _selectedLanguage = 'en';
  String _selectedTimezone = 'America/New_York';
  bool _use24HourFormat = false;
  bool _showUnreadChannelSeparator = true;
  bool _enableColorblindFriendlyTheme = false;
  String _selectedFontSize = 'medium';

  final List<Map<String, String>> _themes = [
    {'value': 'light', 'label': 'Light'},
    {'value': 'dark', 'label': 'Dark'},
    {'value': 'system', 'label': 'Use System Setting'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'en', 'label': 'English'},
    {'value': 'es', 'label': 'Español'},
    {'value': 'fr', 'label': 'Français'},
    {'value': 'de', 'label': 'Deutsch'},
    {'value': 'ja', 'label': '日本語'},
  ];

  final List<Map<String, String>> _timezones = [
    {'value': 'America/New_York', 'label': 'Eastern Time'},
    {'value': 'America/Chicago', 'label': 'Central Time'},
    {'value': 'America/Denver', 'label': 'Mountain Time'},
    {'value': 'America/Los_Angeles', 'label': 'Pacific Time'},
    {'value': 'UTC', 'label': 'UTC'},
  ];

  final List<Map<String, String>> _fontSizes = [
    {'value': 'small', 'label': 'Small'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'large', 'label': 'Large'},
    {'value': 'extra_large', 'label': 'Extra Large'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          _buildThemeSection(),
          const Divider(height: 1),
          _buildLanguageSection(),
          const Divider(height: 1),
          _buildTimeSection(),
          const Divider(height: 1),
          _buildTextSection(),
          const Divider(height: 1),
          _buildAccessibilitySection(),
          const Divider(height: 1),
          _buildChannelDisplaySection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Theme',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ..._themes.map(
          (theme) => RadioListTile<String>(
            title: Text(theme['label']!),
            value: theme['value']!,
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Language',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(
            _languages.firstWhere(
              (lang) => lang['value'] == _selectedLanguage,
            )['label']!,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLanguageDialog();
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Time & Date',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Timezone'),
          subtitle: Text(
            _timezones.firstWhere(
              (tz) => tz['value'] == _selectedTimezone,
            )['label']!,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showTimezoneDialog();
          },
        ),
        SwitchListTile(
          title: const Text('24-hour format'),
          subtitle: const Text('Use 24-hour time format'),
          value: _use24HourFormat,
          onChanged: (value) {
            setState(() {
              _use24HourFormat = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Text',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Font Size'),
          subtitle: Text(
            _fontSizes.firstWhere(
              (size) => size['value'] == _selectedFontSize,
            )['label']!,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showFontSizeDialog();
          },
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Accessibility',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Colorblind friendly theme'),
          subtitle: const Text('Use colors that are easier to distinguish'),
          value: _enableColorblindFriendlyTheme,
          onChanged: (value) {
            setState(() {
              _enableColorblindFriendlyTheme = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChannelDisplaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Channel Display',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Show unread channel separator'),
          subtitle: const Text('Show a line separating read and unread channels'),
          value: _showUnreadChannelSeparator,
          onChanged: (value) {
            setState(() {
              _showUnreadChannelSeparator = value;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return RadioListTile<String>(
                  title: Text(language['label']!),
                  value: language['value']!,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showTimezoneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Timezone'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _timezones.length,
              itemBuilder: (context, index) {
                final timezone = _timezones[index];
                return RadioListTile<String>(
                  title: Text(timezone['label']!),
                  value: timezone['value']!,
                  groupValue: _selectedTimezone,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimezone = value!;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Font Size'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _fontSizes.length,
              itemBuilder: (context, index) {
                final fontSize = _fontSizes[index];
                return RadioListTile<String>(
                  title: Text(fontSize['label']!),
                  value: fontSize['value']!,
                  groupValue: _selectedFontSize,
                  onChanged: (value) {
                    setState(() {
                      _selectedFontSize = value!;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
