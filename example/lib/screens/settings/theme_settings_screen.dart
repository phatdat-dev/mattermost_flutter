import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  ThemeMode _currentThemeMode = ThemeMode.system;
  String _selectedColorScheme = 'blue';
  bool _useSystemColors = false;
  bool _isDarkModeScheduled = false;
  TimeOfDay _darkModeStartTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _darkModeEndTime = const TimeOfDay(hour: 8, minute: 0);

  final Map<String, Color> _colorSchemes = {
    'blue': Colors.blue,
    'purple': Colors.purple,
    'green': Colors.green,
    'orange': Colors.orange,
    'red': Colors.red,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'pink': Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  void _loadThemeSettings() {
    // For now, use default values
    setState(() {
      _currentThemeMode = ThemeMode.system;
      _selectedColorScheme = 'blue';
      _useSystemColors = false;
      _isDarkModeScheduled = false;
    });
  }

  void _saveThemeSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme settings saved successfully')),
    );
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _darkModeStartTime : _darkModeEndTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _darkModeStartTime = picked;
        } else {
          _darkModeEndTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        actions: [
          TextButton(
            onPressed: _saveThemeSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme mode section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how Mattermost looks to you',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    subtitle: const Text('Always use light theme'),
                    value: ThemeMode.light,
                    groupValue: _currentThemeMode,
                    onChanged: (value) => setState(() => _currentThemeMode = value!),
                    contentPadding: EdgeInsets.zero,
                  ),

                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    subtitle: const Text('Always use dark theme'),
                    value: ThemeMode.dark,
                    groupValue: _currentThemeMode,
                    onChanged: (value) => setState(() => _currentThemeMode = value!),
                    contentPadding: EdgeInsets.zero,
                  ),

                  RadioListTile<ThemeMode>(
                    title: const Text('System'),
                    subtitle: const Text('Use system theme setting'),
                    value: ThemeMode.system,
                    groupValue: _currentThemeMode,
                    onChanged: (value) => setState(() => _currentThemeMode = value!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Auto dark mode scheduling
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automatically switch to dark mode during specified hours',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Enable scheduled dark mode'),
                    value: _isDarkModeScheduled,
                    onChanged: (value) => setState(() => _isDarkModeScheduled = value),
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_isDarkModeScheduled) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Dark mode starts'),
                            subtitle: Text(_darkModeStartTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () => _selectTime(context, true),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ListTile(
                            title: const Text('Dark mode ends'),
                            subtitle: Text(_darkModeEndTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () => _selectTime(context, false),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Color scheme section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color Scheme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred accent color',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!_useSystemColors) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _colorSchemes.length,
                      itemBuilder: (context, index) {
                        final entry = _colorSchemes.entries.elementAt(index);
                        final isSelected = _selectedColorScheme == entry.key;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorScheme = entry.key),
                          child: Container(
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.outline,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  SwitchListTile(
                    title: const Text('Use system colors'),
                    subtitle: const Text('Follow system accent color (Android 12+)'),
                    value: _useSystemColors,
                    onChanged: (value) => setState(() => _useSystemColors = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _useSystemColors ? Theme.of(context).colorScheme.primary : _colorSchemes[_selectedColorScheme],
                              child: const Text('M', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mattermost', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('This is how your theme will look'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  backgroundColor: _useSystemColors ? Theme.of(context).colorScheme.primary : _colorSchemes[_selectedColorScheme],
                                ),
                                child: const Text('Primary Button'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Secondary'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Additional settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Reset to defaults'),
                    subtitle: const Text('Restore original theme settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Theme Settings'),
                          content: const Text('Are you sure you want to reset all theme settings to defaults?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _currentThemeMode = ThemeMode.system;
                                  _selectedColorScheme = 'blue';
                                  _useSystemColors = false;
                                  _isDarkModeScheduled = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Theme settings reset to defaults')),
                                );
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Info card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Changes',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Theme changes will be applied immediately after saving. You may need to restart the app for some changes to take full effect.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
