import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class PinnedMessagesScreen extends StatefulWidget {
  final MChannel? channel;

  const PinnedMessagesScreen({
    super.key,
    this.channel,
  });

  @override
  State<PinnedMessagesScreen> createState() => _PinnedMessagesScreenState();
}

class _PinnedMessagesScreenState extends State<PinnedMessagesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _pinnedMessages = [];

  @override
  void initState() {
    super.initState();
    _loadPinnedMessages();
  }

  void _loadPinnedMessages() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load pinned messages from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _pinnedMessages = [
        {
          'id': '1',
          'message': 'Welcome to the team! Please read our guidelines and feel free to ask any questions.',
          'user': {'username': 'manager.one', 'first_name': 'Manager', 'last_name': 'One'},
          'created_at': DateTime.now().subtract(const Duration(days: 30)),
          'pinned_at': DateTime.now().subtract(const Duration(days: 29)),
          'pinned_by': {'username': 'admin', 'first_name': 'Admin', 'last_name': 'User'},
          'reactions': [
            {'emoji': '👍', 'count': 12, 'user_reacted': true},
            {'emoji': '❤️', 'count': 8, 'user_reacted': false},
          ],
          'reply_count': 5,
        },
        {
          'id': '2',
          'message': 'Important: Server maintenance scheduled for this weekend. Please save your work.',
          'user': {'username': 'devops.team', 'first_name': 'DevOps', 'last_name': 'Team'},
          'created_at': DateTime.now().subtract(const Duration(days: 7)),
          'pinned_at': DateTime.now().subtract(const Duration(days: 7)),
          'pinned_by': {'username': 'manager.one', 'first_name': 'Manager', 'last_name': 'One'},
          'reactions': [
            {'emoji': '⚠️', 'count': 15, 'user_reacted': true},
            {'emoji': '👍', 'count': 20, 'user_reacted': false},
          ],
          'reply_count': 12,
        },
        {
          'id': '3',
          'message': 'Great work on the latest release everyone! The client feedback has been overwhelmingly positive.',
          'user': {'username': 'product.manager', 'first_name': 'Product', 'last_name': 'Manager'},
          'created_at': DateTime.now().subtract(const Duration(days: 3)),
          'pinned_at': DateTime.now().subtract(const Duration(days: 2)),
          'pinned_by': {'username': 'manager.one', 'first_name': 'Manager', 'last_name': 'One'},
          'reactions': [
            {'emoji': '🎉', 'count': 25, 'user_reacted': true},
            {'emoji': '👏', 'count': 18, 'user_reacted': true},
            {'emoji': '🚀', 'count': 10, 'user_reacted': false},
          ],
          'reply_count': 8,
        },
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pinned messages: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _unpinMessage(Map<String, dynamic> message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unpin Message'),
        content: const Text('Are you sure you want to unpin this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unpin'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Unpin message via API
      setState(() {
        _pinnedMessages.removeWhere((m) => m['id'] == message['id']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message unpinned')),
        );
      }
    }
  }

  void _toggleReaction(Map<String, dynamic> message, Map<String, dynamic> reaction) {
    setState(() {
      if (reaction['user_reacted']) {
        reaction['count'] = (reaction['count'] as int) - 1;
        reaction['user_reacted'] = false;
      } else {
        reaction['count'] = (reaction['count'] as int) + 1;
        reaction['user_reacted'] = true;
      }
    });

    // TODO: Update reaction via API
  }

  void _jumpToMessage(Map<String, dynamic> message) {
    // TODO: Navigate to original message in channel
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jumping to original message...')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  Widget _buildReactions(Map<String, dynamic> message) {
    final reactions = message['reactions'] as List<dynamic>? ?? [];
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: reactions
          .map(
            (reaction) => InkWell(
              onTap: () => _toggleReaction(message, reaction),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: reaction['user_reacted'] ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: reaction['user_reacted'] ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(reaction['emoji']),
                    const SizedBox(width: 4),
                    Text(
                      '${reaction['count']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: reaction['user_reacted'] ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pinned • ${widget.channel?.displayName ?? 'Channel'}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pinnedMessages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.push_pin_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pinned messages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Important messages will be pinned here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pinnedMessages.length,
              itemBuilder: (context, index) {
                final message = _pinnedMessages[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text(
                                (message['user']['first_name']?[0] ?? message['user']['username'][0]).toUpperCase(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${message['user']['first_name']} ${message['user']['last_name']}'.trim().isEmpty
                                        ? '@${message['user']['username']}'
                                        : '${message['user']['first_name']} ${message['user']['last_name']}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    _formatDate(message['created_at']),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (action) {
                                switch (action) {
                                  case 'jump':
                                    _jumpToMessage(message);
                                    break;
                                  case 'unpin':
                                    _unpinMessage(message);
                                    break;
                                  case 'copy':
                                    // TODO: Copy message text
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Message copied')),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'jump',
                                  child: ListTile(
                                    leading: Icon(Icons.launch),
                                    title: Text('Jump to Message'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: ListTile(
                                    leading: Icon(Icons.copy),
                                    title: Text('Copy Text'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'unpin',
                                  child: ListTile(
                                    leading: Icon(Icons.push_pin, color: Colors.red),
                                    title: Text('Unpin', style: TextStyle(color: Colors.red)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Message content
                        Text(message['message']),

                        const SizedBox(height: 12),

                        // Reactions
                        _buildReactions(message),

                        const SizedBox(height: 8),

                        // Message footer
                        Row(
                          children: [
                            Icon(
                              Icons.push_pin,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pinned by ${message['pinned_by']['first_name']} ${message['pinned_by']['last_name']}'.trim().isEmpty
                                  ? '@${message['pinned_by']['username']}'
                                  : '${message['pinned_by']['first_name']} ${message['pinned_by']['last_name']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${_formatDate(message['pinned_at'])}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (message['reply_count'] > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${message['reply_count']} ${message['reply_count'] == 1 ? 'reply' : 'replies'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _jumpToMessage(message),
                              icon: const Icon(Icons.launch, size: 16),
                              label: const Text('Jump'),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
