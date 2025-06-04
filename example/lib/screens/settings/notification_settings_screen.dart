import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _mentionsOnly = false;
  bool _includeReplyNotifications = true;
  String _soundSelection = 'default';
  bool _vibration = true;
  bool _light = true;

  final List<String> _soundOptions = [
    'default',
    'none',
    'beep',
    'chime',
    'ding',
    'drop',
    'tada',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, you would load these from the server
      // For now, we'll use dummy data
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _emailNotifications = true;
        _pushNotifications = true;
        _mentionsOnly = false;
        _includeReplyNotifications = true;
        _soundSelection = 'default';
        _vibration = true;
        _light = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load preferences: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, you would save these to the server
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification preferences saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save preferences: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePreferences,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildEmailSection(),
                const Divider(height: 1),
                _buildMobileSection(),
                const Divider(height: 1),
                _buildChannelSection(),
                const Divider(height: 1),
                _buildKeywordsSection(),
              ],
            ),
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Email Notifications',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Email Notifications'),
          subtitle: const Text('Receive email notifications when you\'re offline'),
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Email notifications will be sent for mentions and direct messages when you\'re offline.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Mobile Push Notifications',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Push Notifications'),
          subtitle: const Text('Receive mobile notifications even when online'),
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
        if (_pushNotifications) ...[
          SwitchListTile(
            title: const Text('Only for mentions and direct messages'),
            subtitle: const Text('Disable notifications for all activity except mentions'),
            value: _mentionsOnly,
            onChanged: (value) {
              setState(() {
                _mentionsOnly = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Include reply notifications'),
            subtitle: const Text('Receive notifications when someone replies to threads you\'re following'),
            value: _includeReplyNotifications,
            onChanged: (value) {
              setState(() {
                _includeReplyNotifications = value;
              });
            },
          ),
          ListTile(
            title: const Text('Notification Sound'),
            subtitle: Text(_soundSelection == 'none' ? 'No sound' : _soundSelection),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showSoundPicker();
            },
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: _vibration,
            onChanged: (value) {
              setState(() {
                _vibration = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Light'),
            value: _light,
            onChanged: (value) {
              setState(() {
                _light = value;
              });
            },
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Channel Notification Preferences',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Channel-specific Notifications'),
          subtitle: const Text('Configure notifications for individual channels'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/channel-notifications');
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildKeywordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Keywords',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Notification Keywords'),
          subtitle: const Text('Add keywords to trigger notifications'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/notification-keywords');
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Notification Sound',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _soundOptions.length,
                itemBuilder: (context, index) {
                  final sound = _soundOptions[index];
                  return RadioListTile<String>(
                    title: Text(sound),
                    value: sound,
                    groupValue: _soundSelection,
                    onChanged: (value) {
                      setState(() {
                        _soundSelection = value!;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
