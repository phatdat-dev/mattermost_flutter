import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class RecentMentionsScreen extends StatefulWidget {
  const RecentMentionsScreen({super.key});

  @override
  State<RecentMentionsScreen> createState() => _RecentMentionsScreenState();
}

class _RecentMentionsScreenState extends State<RecentMentionsScreen> {
  List<MPost> _mentions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMentions();
  }

  Future<void> _loadMentions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // In a real implementation, load mentions from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock mention data
      final mentions = [
        MPost(
          id: 'mention1',
          createAt: DateTime.now().millisecondsSinceEpoch - 1800000,
          updateAt: DateTime.now().millisecondsSinceEpoch - 1800000,
          deleteAt: 0,
          editAt: 0,
          userId: 'user1',
          channelId: 'general',
          rootId: '',
          originalId: '',
          message: 'Hey @username, can you review the latest changes to the project?',
          type: '',
          props: {},
          fileIds: [],
          metadata: null,
        ),
        MPost(
          id: 'mention2',
          createAt: DateTime.now().millisecondsSinceEpoch - 7200000,
          updateAt: DateTime.now().millisecondsSinceEpoch - 7200000,
          deleteAt: 0,
          editAt: 0,
          userId: 'user2',
          channelId: 'development',
          rootId: '',
          originalId: '',
          message: '@username the deployment is ready for your approval. Please check when you have a moment.',
          type: '',
          props: {},
          fileIds: [],
          metadata: null,
        ),
        MPost(
          id: 'mention3',
          createAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          updateAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          deleteAt: 0,
          editAt: 0,
          userId: 'user3',
          channelId: 'random',
          rootId: '',
          originalId: '',
          message: 'Thanks @username for organizing the team lunch yesterday! 🍕',
          type: '',
          props: {},
          fileIds: [],
          metadata: null,
        ),
      ];

      setState(() {
        _mentions = mentions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load mentions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _markAsRead(MPost post) {
    // In a real implementation, mark the mention as read via API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as read')),
    );
  }

  void _jumpToMessage(MPost post) {
    // In a real implementation, navigate to the message in its channel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jumping to message in ${post.channelId}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Mentions'),
        actions: [
          if (_mentions.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    // Mark all mentions as read
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All mentions marked as read')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Text('Mark all as read'),
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
                    onPressed: _loadMentions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _mentions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alternate_email, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No recent mentions',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'You\'ll see messages that mention you here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMentions,
              child: ListView.builder(
                itemCount: _mentions.length,
                itemBuilder: (context, index) {
                  final mention = _mentions[index];
                  return _buildMentionItem(mention);
                },
              ),
            ),
    );
  }

  Widget _buildMentionItem(MPost mention) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _jumpToMessage(mention),
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
                      mention.userId.substring(0, 2).toUpperCase(),
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
                              mention.userId, // In a real app, resolve to username
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
                              '#${mention.channelId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatTimestamp(mention.createAt!),
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
                        case 'mark_read':
                          _markAsRead(mention);
                          break;
                        case 'jump':
                          _jumpToMessage(mention);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: Text('Mark as read'),
                      ),
                      const PopupMenuItem(
                        value: 'jump',
                        child: Text('Jump to message'),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Message content with highlighted mention
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: _highlightMention(mention.message),
                ),
              ),

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
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _highlightMention(String text) {
    final List<TextSpan> spans = [];
    final mentionRegex = RegExp(r'@\w+');
    int lastEnd = 0;

    for (final match in mentionRegex.allMatches(text)) {
      // Add text before mention
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Add highlighted mention
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.w600,
            backgroundColor: Colors.blue[50],
          ),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
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
