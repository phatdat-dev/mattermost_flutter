import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

void main() {
  runApp(const MattermostApp());
}

class MattermostApp extends StatelessWidget {
  const MattermostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mattermost Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark, useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with example values for testing
    _serverController.text = 'https://your-mattermost-server.com';
    _usernameController.text = '';
    _passwordController.text = '';
    _tokenController.text = '';
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize the Mattermost client
      final client = MattermostClient(config: MattermostConfig(baseUrl: _serverController.text, enableDebugLogs: true));

      if (_tokenController.text.isNotEmpty) {
        // Or use token-based authentication
        await client.login(token: _tokenController.text);
      } else {
        // Login with provided credentials
        await client.login(loginId: _usernameController.text, password: _passwordController.text);
      }

      // Get current user information
      final currentUser = await client.users.getMe();

      if (!mounted) return;

      // Navigate to the dashboard on successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(client: client, currentUser: currentUser),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mattermost Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'https://your-mattermost-server.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter server URL';
                      }
                      if (!value.startsWith('http')) {
                        return 'URL must start with http:// or https://';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username or Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter username or email';
                    //   }
                    //   return null;
                    // },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter password';
                    //   }
                    //   return null;
                    // },
                  ),
                  // Optional token-based authentication
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: 'Or Login with Token (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 10) {
                        return 'Token must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;

  const DashboardScreen({super.key, required this.client, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<MTeam> _teams = [];
  MTeam? _selectedTeam;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    widget.client.webSocket.events.listen((event) {
      // Handle WebSocket events
      if (event['event'] == 'hello') {
        debugPrint('WebSocket connected');
      } else if (event['event'] == 'posted') {
        // Refresh data when a new post is created
        if (mounted) {
          _loadTeams();
        }
      }
    });
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get teams for the current user
      _teams = await widget.client.teams.getTeamsForUser(widget.currentUser.id);

      if (_teams.isNotEmpty) {
        _selectedTeam = _teams.first;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load teams: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await widget.client.logout();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTeam?.displayName ?? 'Mattermost'),
        actions: [IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout, tooltip: 'Logout')],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Channels'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Direct Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('${widget.currentUser.firstName} ${widget.currentUser.lastName}'),
            accountEmail: Text(widget.currentUser.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.currentUser.username.isNotEmpty ? widget.currentUser.username[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          const ListTile(
            title: Text('Teams', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ..._teams.map(
            (team) => ListTile(
              title: Text(team.displayName),
              selected: _selectedTeam?.id == team.id,
              onTap: () {
                setState(() {
                  _selectedTeam = team;
                });
                Navigator.pop(context);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _selectedTeam != null
            ? ChannelsScreen(client: widget.client, currentUser: widget.currentUser, team: _selectedTeam!)
            : const Center(child: Text('No team selected'));
      case 1:
        return DirectMessagesScreen(client: widget.client, currentUser: widget.currentUser);
      case 2:
        return ProfileScreen(client: widget.client, currentUser: widget.currentUser);
      default:
        return const Center(child: Text('Unknown screen'));
    }
  }
}

class ChannelsScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MTeam team;

  const ChannelsScreen({super.key, required this.client, required this.currentUser, required this.team});

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
      _channels = await widget.client.channels.getChannelsForUser(widget.currentUser.id, widget.team.id);
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
        await widget.client.channels.createChannel(
          MCreateChannelRequest(
            teamId: widget.team.id,
            name: result['name']!.toLowerCase().replaceAll(' ', '-'),
            displayName: result['displayName']!,
            type: result['type']!,
            purpose: result['purpose'] ?? '',
            header: result['header'] ?? '',
          ),
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
                        builder: (context) => ChannelScreen(client: widget.client, currentUser: widget.currentUser, channel: channel),
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
  final MattermostClient client;
  final MUser currentUser;
  final MChannel channel;

  const ChannelScreen({super.key, required this.client, required this.currentUser, required this.channel});

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
    _websocketSubscription = widget.client.webSocket.events.listen((event) {
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
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);

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
      await widget.client.posts.createPost(MCreatePostRequest(channelId: widget.channel.id, message: message));

      // Reload posts after sending a message
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _addReaction(MPost post, String emoji) async {
    try {
      await widget.client.posts.addReaction(MReactionRequest(userId: widget.currentUser.id, postId: post.id, emojiName: emoji));

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
                          currentUserId: widget.currentUser.id,
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
                color: isCurrentUser ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
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

class DirectMessagesScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;

  const DirectMessagesScreen({super.key, required this.client, required this.currentUser});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final _searchController = TextEditingController();
  List<MChannel> _directChannels = [];
  List<MUser> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadDirectChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadDirectChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all channels for the current user
      final allChannels = await Future.wait(
        (await widget.client.teams.getTeamsForUser(
          widget.currentUser.id,
        )).map((team) => widget.client.channels.getChannelsForUser(widget.currentUser.id, team.id)),
      );

      // Flatten the list and filter direct message channels (type 'D')
      final directChannels = allChannels.expand((channels) => channels).where((channel) => channel.type == 'D').toList();

      setState(() {
        _directChannels = directChannels;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load direct messages: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchUsers(String term) async {
    if (term.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final request = MUserSearchRequest(term: term, limit: 20);
      final users = await widget.client.users.searchUsers(request);

      // Filter out the current user
      setState(() {
        _searchResults = users.where((user) => user.id != widget.currentUser.id).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(value);
    });
  }

  Future<void> _startDirectChat(MUser user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a direct message channel
      final channel = await widget.client.channels.createDirectChannel(widget.currentUser.id, user.id);

      if (!mounted) return;

      // Navigate to the chat screen
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => DirectChatScreen(client: widget.client, currentUser: widget.currentUser, otherUser: user, channel: channel),
            ),
          )
          .then((_) {
            // Refresh the list when returning from chat
            _loadDirectChannels();
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create direct message: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openExistingChat(MChannel channel) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the other user's ID from the channel name
      // Direct message channel names are in the format [user_id]__[other_user_id]
      final userIds = channel.name.split('__');
      final otherUserId = userIds[0] == widget.currentUser.id ? userIds[1] : userIds[0];

      // Get the other user's details
      final otherUser = await widget.client.users.getUser(otherUserId);

      if (!mounted) return;

      // Navigate to the chat screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DirectChatScreen(client: widget.client, currentUser: widget.currentUser, otherUser: otherUser, channel: channel),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Search results or direct message list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _searchResults.isNotEmpty
                ? _buildSearchResults()
                : _searchController.text.isNotEmpty && _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isNotEmpty && _searchResults.isEmpty
                ? const Center(child: Text('No users found'))
                : _buildDirectChannelsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _createGroupChat, tooltip: 'Create Group Chat', child: const Icon(Icons.group_add)),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
          ),
          title: Text(user.username),
          subtitle: Text('${user.firstName} ${user.lastName}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chat),
          onTap: () => _startDirectChat(user),
        );
      },
    );
  }

  Widget _buildDirectChannelsList() {
    if (_directChannels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No direct messages yet'),
            const SizedBox(height: 16),
            const Text('Search for users to start a conversation'),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _createGroupChat, icon: const Icon(Icons.group_add), label: const Text('Create Group Chat')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDirectChannels,
      child: ListView.builder(
        itemCount: _directChannels.length,
        itemBuilder: (context, index) {
          final channel = _directChannels[index];
          return FutureBuilder<Widget>(
            future: _buildDirectChannelTile(channel),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
                  title: Text('Loading...'),
                );
              }
              return snapshot.data ?? const SizedBox();
            },
          );
        },
      ),
    );
  }

  Future<void> _createGroupChat() async {
    final selectedUsers = await Navigator.of(context).push<List<MUser>>(
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(client: widget.client, currentUser: widget.currentUser, existingMembers: []),
      ),
    );

    if (selectedUsers != null && selectedUsers.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Add current user to the list
        final allMembers = [widget.currentUser, ...selectedUsers];
        final userIds = allMembers.map((user) => user.id).toList();

        // Create group message channel
        final channel = await widget.client.channels.createGroupChannel(userIds);

        if (!mounted) return;

        // Navigate to the group chat screen
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => GroupChatScreen(client: widget.client, currentUser: widget.currentUser, channel: channel, members: allMembers),
              ),
            )
            .then((_) {
              // Refresh the list when returning from chat
              _loadDirectChannels();
            });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create group chat: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<Widget> _buildDirectChannelTile(MChannel channel) async {
    try {
      // Get the other user's ID from the channel name
      final userIds = channel.name.split('__');
      final otherUserId = userIds[0] == widget.currentUser.id ? userIds[1] : userIds[0];

      // Get the other user's details
      final otherUser = await widget.client.users.getUser(otherUserId);

      // Get the last message in the channel
      final postList = await widget.client.posts.getPostsForChannel(channel.id, perPage: 1);
      final lastPost = postList.posts.isNotEmpty ? postList.posts.values.first : null;

      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(otherUser.username.isNotEmpty ? otherUser.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(otherUser.username),
        subtitle: lastPost != null ? Text(lastPost.message, maxLines: 1, overflow: TextOverflow.ellipsis) : const Text('No messages yet'),
        trailing: lastPost != null
            ? Text(_formatTimestamp(lastPost.createAt ?? 0), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color))
            : null,
        onTap: () => _openExistingChat(channel),
      );
    } catch (e) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.error,
          child: const Icon(Icons.error, color: Colors.white),
        ),
        title: const Text('Error loading chat'),
        subtitle: Text(e.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }
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

class DirectChatScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MUser otherUser;
  final MChannel channel;

  const DirectChatScreen({super.key, required this.client, required this.currentUser, required this.otherUser, required this.channel});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<MPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _websocketSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _setupWebSocket();

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshPosts();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _websocketSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupWebSocket() {
    _websocketSubscription = widget.client.webSocket.events.listen((event) {
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
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);

      setState(() {
        _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    if (_isLoading) return;

    try {
      // Get posts for the channel
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);

      if (mounted) {
        setState(() {
          _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
        });
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await widget.client.posts.createPost(MCreatePostRequest(channelId: widget.channel.id, message: message));

      // Reload posts after sending a message
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _addReaction(MPost post, String emoji) async {
    try {
      await widget.client.posts.addReaction(MReactionRequest(userId: widget.currentUser.id, postId: post.id, emojiName: emoji));

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
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: Text(
                widget.otherUser.username.isNotEmpty ? widget.otherUser.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUser.username),
                  if (widget.otherUser.firstName.isNotEmpty || widget.otherUser.lastName.isNotEmpty)
                    Text('${widget.otherUser.firstName} ${widget.otherUser.lastName}'.trim(), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show user info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.otherUser.username),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${widget.otherUser.id}'),
                      const SizedBox(height: 8),
                      Text('Name: ${widget.otherUser.firstName} ${widget.otherUser.lastName}'),
                      const SizedBox(height: 8),
                      Text('Email: ${widget.otherUser.email}'),
                      const SizedBox(height: 8),
                      Text('Position: ${widget.otherUser.position}'),
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
                        return DirectMessageTile(
                          post: post,
                          currentUser: widget.currentUser,
                          otherUser: widget.otherUser,
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

class DirectMessageTile extends StatelessWidget {
  final MPost post;
  final MUser currentUser;
  final MUser otherUser;
  final VoidCallback onReactionTap;

  const DirectMessageTile({super.key, required this.post, required this.currentUser, required this.otherUser, required this.onReactionTap});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = post.userId == currentUser.id;
    final user = isCurrentUser ? currentUser : otherUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
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
              child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
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

class GroupChatScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MChannel channel;
  final List<MUser> members;

  const GroupChatScreen({super.key, required this.client, required this.currentUser, required this.channel, required this.members});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<MPost> _posts = [];
  List<MUser> _members = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _websocketSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members);
    _loadPosts();
    _setupWebSocket();

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshPosts();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _websocketSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupWebSocket() {
    _websocketSubscription = widget.client.webSocket.events.listen((event) {
      if (event['event'] == 'posted' && event['data'] != null && event['data']['channel_id'] == widget.channel.id) {
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
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);
      setState(() {
        _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    if (_isLoading) return;

    try {
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);
      if (mounted) {
        setState(() {
          _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
        });
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await widget.client.posts.createPost(MCreatePostRequest(channelId: widget.channel.id, message: message));
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _addMembers() async {
    final result = await Navigator.of(context).push<List<MUser>>(
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(client: widget.client, currentUser: widget.currentUser, existingMembers: _members),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _members.addAll(result);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${result.length} member(s) to the group')));
    }
  }

  Future<void> _showMembersList() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => MembersListSheet(
        members: _members,
        currentUser: widget.currentUser,
        onRemoveMember: (user) {
          setState(() {
            _members.removeWhere((member) => member.id == user.id);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed ${user.username} from the group')));
        },
      ),
    );
  }

  String _getGroupName() {
    if (_members.length <= 3) {
      return _members.map((m) => m.username).join(', ');
    } else {
      return '${_members.take(2).map((m) => m.username).join(', ')} and ${_members.length - 2} others';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGroupName(), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${_members.length} members', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: _addMembers, tooltip: 'Add Members'),
          IconButton(icon: const Icon(Icons.people), onPressed: _showMembersList, tooltip: 'View Members'),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Group Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Channel ID: ${widget.channel.id}'),
                      const SizedBox(height: 8),
                      Text('Members: ${_members.length}'),
                      const SizedBox(height: 8),
                      Text('Type: Group Chat'),
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
                        final sender = _members.firstWhere((member) => member.id == post.userId, orElse: () => widget.currentUser);
                        return GroupMessageTile(post: post, sender: sender, currentUser: widget.currentUser);
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

class AddMembersScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final List<MUser> existingMembers;

  const AddMembersScreen({super.key, required this.client, required this.currentUser, required this.existingMembers});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final _searchController = TextEditingController();
  List<MUser> _searchResults = [];
  final List<MUser> _selectedUsers = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchUsers(String term) async {
    if (term.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final request = MUserSearchRequest(term: term, limit: 20);
      final users = await widget.client.users.searchUsers(request);

      // Filter out current user and existing members
      final existingIds = widget.existingMembers.map((u) => u.id).toSet();
      existingIds.add(widget.currentUser.id);

      setState(() {
        _searchResults = users.where((user) => !existingIds.contains(user.id)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(value);
    });
  }

  void _toggleUserSelection(MUser user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedUsers);
              },
              child: Text('Add (${_selectedUsers.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_selectedUsers.isNotEmpty)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedUsers[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            label: Text(user.username),
                            onDeleted: () => _toggleUserSelection(user),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text('No users found'))
                : _searchController.text.isEmpty
                ? const Center(child: Text('Search for users to add to the group'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      final isSelected = _selectedUsers.contains(user);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(user.username),
                        subtitle: Text('${user.firstName} ${user.lastName}'.trim()),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.add_circle_outline),
                        onTap: () => _toggleUserSelection(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MembersListSheet extends StatelessWidget {
  final List<MUser> members;
  final MUser currentUser;
  final Function(MUser) onRemoveMember;

  const MembersListSheet({super.key, required this.members, required this.currentUser, required this.onRemoveMember});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group Members (${members.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isCurrentUser = member.id == currentUser.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(member.username.isNotEmpty ? member.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(member.username),
                  subtitle: Text('${member.firstName} ${member.lastName}'.trim()),
                  trailing: isCurrentUser
                      ? const Chip(label: Text('You'))
                      : IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove Member'),
                                content: Text('Are you sure you want to remove ${member.username} from the group?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onRemoveMember(member);
                                    },
                                    child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GroupMessageTile extends StatelessWidget {
  final MPost post;
  final MUser sender;
  final MUser currentUser;

  const GroupMessageTile({super.key, required this.post, required this.sender, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = post.userId == currentUser.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: Text(
                sender.username.isNotEmpty ? sender.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      sender.username,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  Text(post.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    post.createAt != null ? _formatTimestamp(post.createAt!) : 'Unknown time',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: Text(
                sender.username.isNotEmpty ? sender.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
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

class ProfileScreen extends StatelessWidget {
  final MattermostClient client;
  final MUser currentUser;

  const ProfileScreen({super.key, required this.client, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              currentUser.username.isNotEmpty ? currentUser.username[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('${currentUser.firstName} ${currentUser.lastName}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('@${currentUser.username}', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Text(currentUser.email, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              // Navigate to edit profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Preferences'),
            onTap: () {
              // Navigate to notification preferences screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security Settings'),
            onTap: () {
              // Navigate to security settings screen
            },
          ),
          const Spacer(),
          const Text('Mattermost Flutter Demo', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
