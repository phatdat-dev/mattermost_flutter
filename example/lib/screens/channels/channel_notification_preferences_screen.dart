import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';

class ChannelNotificationPreferencesScreen extends StatefulWidget {
  final MChannel channel;

  const ChannelNotificationPreferencesScreen({
    super.key,
    required this.channel,
  });

  @override
  State<ChannelNotificationPreferencesScreen> createState() => _ChannelNotificationPreferencesScreenState();
}

class _ChannelNotificationPreferencesScreenState extends State<ChannelNotificationPreferencesScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Notification preferences
  String _desktopNotification = 'default';
  String _mobileNotification = 'default';
  String _markUnread = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    setState(() => _isLoading = true);

    try {
      // Load current notification preferences for the channel
      final member = await AppRoutes.client.channels.getChannelMember(widget.channel.id, AppRoutes.currentUser!.id);

      final notifyProps = member.notifyProps;
      setState(() {
        _desktopNotification = notifyProps?.desktop ?? 'default';
        _mobileNotification = notifyProps?.push ?? 'default';
        _markUnread = notifyProps?.markUnread ?? 'all';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notification preferences: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNotificationPreferences() async {
    setState(() => _isLoading = true);

    try {
      final notifyProps = MChannelNotifyProps(
        desktop: _desktopNotification,
        push: _mobileNotification,
        markUnread: _markUnread,
      );

      await AppRoutes.client.channels.updateChannelMemberNotifyProps(
        widget.channel.id,
        AppRoutes.currentUser!.id,
        notifyProps,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update notification preferences: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveNotificationPreferences,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotificationPreferences,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Channel info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            widget.channel.type == 'O' ? Icons.tag : Icons.lock,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.channel.displayName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.channel.purpose.isNotEmpty)
                                  Text(
                                    widget.channel.purpose,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Desktop notifications
                  _buildNotificationSection(
                    'Desktop Notifications',
                    'Control desktop notifications for this channel',
                    _desktopNotification,
                    (value) => setState(() => _desktopNotification = value!),
                    const [
                      ('default', 'Use global setting'),
                      ('all', 'For all activity'),
                      ('mention', 'Only for mentions'),
                      ('none', 'Never'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mobile notifications
                  _buildNotificationSection(
                    'Mobile Push Notifications',
                    'Control mobile push notifications for this channel',
                    _mobileNotification,
                    (value) => setState(() => _mobileNotification = value!),
                    const [
                      ('default', 'Use global setting'),
                      ('all', 'For all activity'),
                      ('mention', 'Only for mentions'),
                      ('none', 'Never'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mark unread
                  _buildNotificationSection(
                    'Mark Channel Unread',
                    'Control when the channel is marked as unread',
                    _markUnread,
                    (value) => setState(() => _markUnread = value!),
                    const [
                      ('all', 'For all unread messages'),
                      ('mention', 'Only for mentions'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Information card
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
                                  'Channel-specific Settings',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'These settings only apply to this channel and override your global notification preferences.',
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
            ),
    );
  }

  Widget _buildNotificationSection(
    String title,
    String subtitle,
    String currentValue,
    ValueChanged<String?> onChanged,
    List<(String, String)> options,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: options.map((option) {
                return RadioListTile<String>(
                  title: Text(option.$2),
                  value: option.$1,
                  groupValue: currentValue,
                  onChanged: onChanged,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
