import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class SavedMessagesScreen extends StatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
  List<MPost> _savedMessages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedMessages();
  }

  Future<void> _loadSavedMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // In a real implementation, load saved messages from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock saved message data
      final savedMessages = [
        MPost(
          id: 'saved1',
          createAt: DateTime.now().millisecondsSinceEpoch - 3600000,
          updateAt: DateTime.now().millisecondsSinceEpoch - 3600000,
          deleteAt: 0,
          editAt: 0,
          userId: 'user1',
          channelId: 'general',
          rootId: '',
          originalId: '',
          message: 'Important meeting notes: Q2 planning session scheduled for next Friday at 2 PM',
          type: '',
          props: {},
          fileIds: [],
          metadata: null,
        ),
        MPost(
          id: 'saved2',
          createAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          updateAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          deleteAt: 0,
          editAt: 0,
          userId: 'user2',
          channelId: 'development',
          rootId: '',
          originalId: '',
          message: 'API documentation link: https://docs.mattermost.com/api - bookmark this for reference',
          type: '',
          props: {},
          fileIds: [],
          metadata: null,
        ),
        MPost(
          id: 'saved3',
          createAt: DateTime.now().millisecondsSinceEpoch - 172800000,
          updateAt: DateTime.now().millisecondsSinceEpoch - 172800000,
          deleteAt: 0,
          editAt: 0,
          userId: 'user3',
          channelId: 'random',
          rootId: '',
          originalId: '',
          message: 'Great recipe for team lunch: Chicken Teriyaki Bowl - ingredients and instructions in the thread 🍜',
          type: '',
          props: {},
          fileIds: [],
          metadata: null,
        ),
      ];

      setState(() {
        _savedMessages = savedMessages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load saved messages: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _unsaveMessage(MPost post) {
    setState(() {
      _savedMessages.removeWhere((message) => message.id == post.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message removed from saved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _savedMessages.add(post);
            });
          },
        ),
      ),
    );
  }

  void _jumpToMessage(MPost post) {
    // In a real implementation, navigate to the message in its channel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jumping to message in #${post.channelId}')),
    );
  }

  void _shareMessage(MPost post) {
    // In a real implementation, share the message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing message...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Messages'),
        actions: [
          if (_savedMessages.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'clear_all':
                    _showClearAllDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Clear all saved'),
                ),
              ],
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
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSavedMessages,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _savedMessages.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No saved messages',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Tap the bookmark icon on any message to save it',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSavedMessages,
              child: ListView.builder(
                itemCount: _savedMessages.length,
                itemBuilder: (context, index) {
                  final message = _savedMessages[index];
                  return _buildSavedMessageItem(message);
                },
              ),
            ),
    );
  }

  Widget _buildSavedMessageItem(MPost message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _jumpToMessage(message),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      message.userId.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              message.userId, // In a real app, resolve to username
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'in',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '#${message.channelId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatTimestamp(message.createAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'unsave':
                          _unsaveMessage(message);
                          break;
                        case 'jump':
                          _jumpToMessage(message);
                          break;
                        case 'share':
                          _shareMessage(message);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'jump',
                        child: Text('Jump to message'),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Text('Share'),
                      ),
                      const PopupMenuItem(
                        value: 'unsave',
                        child: Text('Remove from saved'),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Message content
              Text(message.message),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    '{00} replies',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Saved indicator
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Saved Messages'),
        content: const Text(
          'Are you sure you want to remove all saved messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savedMessages.clear();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All saved messages cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
