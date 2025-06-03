import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _mentionsOnly = false;
  bool _allActivity = true;
  bool _directMessages = true;
  bool _groupMessages = true;
  bool _channelMentions = true;
  bool _keywords = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _ledNotification = false;
  String _notificationSound = 'default';
  String _emailInterval = 'immediate';
  String _desktopNotifications = 'all';
  bool _mobileOfflineOnly = false;
  String _keywordsList = '@channel, @here, urgent';

  final List<Map<String, String>> _soundOptions = [
    {'value': 'default', 'label': 'Default'},
    {'value': 'bing', 'label': 'Bing'},
    {'value': 'crackle', 'label': 'Crackle'},
    {'value': 'down', 'label': 'Down'},
    {'value': 'hello', 'label': 'Hello'},
    {'value': 'uptown', 'label': 'Uptown'},
  ];

  final List<Map<String, String>> _emailIntervals = [
    {'value': 'immediate', 'label': 'Immediately'},
    {'value': 'fifteen', 'label': 'Every 15 minutes'},
    {'value': 'hour', 'label': 'Every hour'},
    {'value': 'never', 'label': 'Never'},
  ];

  final List<Map<String, String>> _desktopOptions = [
    {'value': 'all', 'label': 'For all activity'},
    {'value': 'mentions', 'label': 'Only for mentions and direct messages'},
    {'value': 'never', 'label': 'Never'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          _buildMobileNotificationsSection(),
          const Divider(height: 1),
          _buildEmailNotificationsSection(),
          const Divider(height: 1),
          _buildDesktopNotificationsSection(),
          const Divider(height: 1),
          _buildNotificationTriggerSection(),
          const Divider(height: 1),
          _buildSoundAndVibrationSection(),
          const Divider(height: 1),
          _buildKeywordsSection(),
        ],
      ),
    );
  }

  Widget _buildMobileNotificationsSection() {
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
          title: const Text('Send push notifications'),
          subtitle: const Text('Enable mobile push notifications'),
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
        if (_pushNotifications) ...[
          SwitchListTile(
            title: const Text('Only when offline'),
            subtitle: const Text('Only send notifications when offline or away'),
            value: _mobileOfflineOnly,
            onChanged: (value) {
              setState(() {
                _mobileOfflineOnly = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEmailNotificationsSection() {
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
          title: const Text('Send email notifications'),
          subtitle: const Text('Enable email notifications'),
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        if (_emailNotifications) ...[
          ListTile(
            title: const Text('Email notification interval'),
            subtitle: Text(
              _emailIntervals.firstWhere(
                (interval) => interval['value'] == _emailInterval,
              )['label']!,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showEmailIntervalDialog();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Desktop Notifications',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Desktop notifications'),
          subtitle: Text(
            _desktopOptions.firstWhere(
              (option) => option['value'] == _desktopNotifications,
            )['label']!,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showDesktopNotificationsDialog();
          },
        ),
      ],
    );
  }

  Widget _buildNotificationTriggerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Notification Triggers',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        RadioListTile<bool>(
          title: const Text('For all activity'),
          subtitle: const Text('Notify me about all messages and activity'),
          value: true,
          groupValue: _allActivity,
          onChanged: (value) {
            setState(() {
              _allActivity = value!;
              _mentionsOnly = !value;
            });
          },
        ),
        RadioListTile<bool>(
          title: const Text('Only for mentions and direct messages'),
          subtitle: const Text('Only notify me when I am mentioned or receive a direct message'),
          value: false,
          groupValue: _allActivity,
          onChanged: (value) {
            setState(() {
              _allActivity = !value!;
              _mentionsOnly = value;
            });
          },
        ),
        if (!_mentionsOnly) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Specific notification types:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          CheckboxListTile(
            title: const Text('Direct messages'),
            value: _directMessages,
            onChanged: (value) {
              setState(() {
                _directMessages = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Group messages'),
            value: _groupMessages,
            onChanged: (value) {
              setState(() {
                _groupMessages = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Channel-wide mentions (@channel, @all, @here)'),
            value: _channelMentions,
            onChanged: (value) {
              setState(() {
                _channelMentions = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Keyword mentions'),
            value: _keywords,
            onChanged: (value) {
              setState(() {
                _keywords = value!;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSoundAndVibrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Sound & Vibration',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Sound'),
          subtitle: const Text('Play notification sounds'),
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        if (_soundEnabled) ...[
          ListTile(
            title: const Text('Notification sound'),
            subtitle: Text(
              _soundOptions.firstWhere(
                (sound) => sound['value'] == _notificationSound,
              )['label']!,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showSoundDialog();
            },
          ),
        ],
        SwitchListTile(
          title: const Text('Vibration'),
          subtitle: const Text('Vibrate when receiving notifications'),
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('LED notification'),
          subtitle: const Text('Blink LED when receiving notifications'),
          value: _ledNotification,
          onChanged: (value) {
            setState(() {
              _ledNotification = value;
            });
          },
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Keywords that trigger notifications',
              helperText: 'Separate keywords with commas',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            controller: TextEditingController(text: _keywordsList),
            onChanged: (value) {
              setState(() {
                _keywordsList = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showEmailIntervalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Notification Interval'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _emailIntervals.length,
              itemBuilder: (context, index) {
                final interval = _emailIntervals[index];
                return RadioListTile<String>(
                  title: Text(interval['label']!),
                  value: interval['value']!,
                  groupValue: _emailInterval,
                  onChanged: (value) {
                    setState(() {
                      _emailInterval = value!;
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

  void _showDesktopNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Desktop Notifications'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _desktopOptions.length,
              itemBuilder: (context, index) {
                final option = _desktopOptions[index];
                return RadioListTile<String>(
                  title: Text(option['label']!),
                  value: option['value']!,
                  groupValue: _desktopNotifications,
                  onChanged: (value) {
                    setState(() {
                      _desktopNotifications = value!;
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

  void _showSoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Sound'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _soundOptions.length,
              itemBuilder: (context, index) {
                final sound = _soundOptions[index];
                return RadioListTile<String>(
                  title: Text(sound['label']!),
                  value: sound['value']!,
                  groupValue: _notificationSound,
                  onChanged: (value) {
                    setState(() {
                      _notificationSound = value!;
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
