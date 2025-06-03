import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';

class ChannelsScreen extends StatefulWidget {
  final MTeam team;

  const ChannelsScreen({super.key, required this.team});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  List<MChannel> _channels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void didUpdateWidget(ChannelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team.id != widget.team.id) {
      _loadChannels();
    }
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get channels for the selected team
      _channels = await AppRoutes.client.channels.getChannelsForUser(AppRoutes.currentUser!.id, widget.team.id);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load channels: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createChannel() async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (context) => const CreateChannelDialog());

    if (result != null) {
      try {
        await AppRoutes.client.channels.createChannel(
          teamId: widget.team.id,
          name: result['name']!.toLowerCase().replaceAll(' ', '-'),
          displayName: result['displayName']!,
          type: result['type']!,
          purpose: result['purpose'] ?? '',
          header: result['header'] ?? '',
        );

        // Reload channels after creating a new one
        _loadChannels();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create channel: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Scaffold(
      body: _channels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No channels found'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _createChannel, child: const Text('Create Channel')),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _channels.length,
              itemBuilder: (context, index) {
                final channel = _channels[index];
                return ListTile(
                  leading: Icon(channel.type == 'O' ? Icons.tag : Icons.lock, color: Theme.of(context).colorScheme.primary),
                  title: Text(channel.displayName),
                  subtitle: channel.purpose.isNotEmpty ? Text(channel.purpose, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChannelScreen(channel: channel),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: _createChannel, tooltip: 'Create Channel', child: const Icon(Icons.add)),
    );
  }
}

class CreateChannelDialog extends StatefulWidget {
  const CreateChannelDialog({super.key});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _headerController = TextEditingController();
  String _channelType = 'O'; // Default to public channel

  @override
  void dispose() {
    _displayNameController.dispose();
    _purposeController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Channel'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name', hintText: 'Enter channel name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(labelText: 'Purpose (Optional)', hintText: 'Enter channel purpose'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _headerController,
                decoration: const InputDecoration(labelText: 'Header (Optional)', hintText: 'Enter channel header'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _channelType,
                decoration: const InputDecoration(labelText: 'Channel Type'),
                items: const [
                  DropdownMenuItem(value: 'O', child: Text('Public')),
                  DropdownMenuItem(value: 'P', child: Text('Private')),
                ],
                onChanged: (value) {
                  setState(() {
                    _channelType = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'displayName': _displayNameController.text,
                'name': _displayNameController.text.toLowerCase().replaceAll(' ', '-'),
                'purpose': _purposeController.text,
                'header': _headerController.text,
                'type': _channelType,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class ChannelScreen extends StatefulWidget {
  final MChannel channel;

  const ChannelScreen({super.key, required this.channel});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<MPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _websocketSubscription;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _setupWebSocket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _websocketSubscription?.cancel();
    super.dispose();
  }

  void _setupWebSocket() {
    _websocketSubscription = AppRoutes.client.webSocket.events.listen((event) {
      if (event['event'] == 'posted' && event['data'] != null && event['data']['channel_id'] == widget.channel.id) {
        // Reload posts when a new message is posted in this channel
        _loadPosts();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get posts for the channel
      final postList = await AppRoutes.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);

      setState(() {
        _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await AppRoutes.client.posts.createPost(channelId: widget.channel.id, message: message);

      // Reload posts after sending a message
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _addReaction(MPost post, String emoji) async {
    try {
      await AppRoutes.client.posts.addReaction(userId: AppRoutes.currentUser!.id, postId: post.id, emojiName: emoji);

      // Reload posts after adding a reaction
      _loadPosts();
    } catch (e) {
      debugPrint('Failed to add reaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add reaction: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.channel.displayName),
            if (widget.channel.purpose.isNotEmpty) Text(widget.channel.purpose, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show channel info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.channel.displayName),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${widget.channel.id}'),
                      const SizedBox(height: 8),
                      Text('Type: ${widget.channel.type == "O" ? "Public" : "Private"}'),
                      const SizedBox(height: 8),
                      Text('Purpose: ${widget.channel.purpose}'),
                      const SizedBox(height: 8),
                      Text('Header: ${widget.channel.header}'),
                    ],
                  ),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _posts.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return MessageTile(
                          post: post,
                          currentUserId: AppRoutes.currentUser!.id,
                          onReactionTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => ReactionPicker(
                                onEmojiSelected: (emoji) {
                                  Navigator.pop(context);
                                  _addReaction(post, emoji);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // File attachment functionality
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24.0))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final MPost post;
  final String currentUserId;
  final VoidCallback onReactionTap;

  const MessageTile({super.key, required this.post, required this.currentUserId, required this.onReactionTap});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = post.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(post.userId.isNotEmpty ? post.userId[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        post.createAt != null ? _formatTimestamp(post.createAt!) : 'Unknown time',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      const SizedBox(width: 8),
                      InkWell(onTap: onReactionTap, child: const Icon(Icons.emoji_emotions_outlined, size: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(currentUserId.isNotEmpty ? currentUserId[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
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

class ReactionPicker extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const ReactionPicker({super.key, required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    // https://docs.mattermost.com/collaborate/react-with-emojis-gifs.html
    // Simple emoji picker with common emojis
    final emojis = ['👍', '👎', '❤️', '😄', '😢', '😮', '🎉', '🚀', '👀', '🙌', '👏', '🔥'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Reaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => onEmojiSelected(emojis[index]),
                  child: Center(child: Text(emojis[index], style: const TextStyle(fontSize: 24))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
