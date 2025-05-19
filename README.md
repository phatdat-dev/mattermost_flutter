# Mattermost Flutter

# [![Mattermost logo](https://user-images.githubusercontent.com/7205829/137170381-fe86eef0-bccc-4fdd-8e92-b258884ebdd7.png)](https://mattermost.com)

[![Pub Version](https://img.shields.io/pub/v/mattermost_flutter)](https://pub.dev/packages/mattermost_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package that provides complete access to the Mattermost API. This package enables Flutter developers to easily integrate Mattermost functionality into their applications with a clean, type-safe Dart interface.

The package covers all Mattermost API endpoints including authentication, users, teams, channels, posts, files, webhooks, and real-time WebSocket communication. It features robust error handling, comprehensive documentation, and practical examples to help you get started quickly.

Built with Flutter best practices and designed for performance, this package is ideal for building custom Mattermost clients, chat integrations, notification systems, or any application that needs to interact with a Mattermost server.

## Features

- 🔐 **Complete Authentication**: Login, logout, and token management
- 👥 **Users & Teams**: User management, team creation and management
- 💬 **Channels & Messages**: Create and manage channels, send and receive messages
- 📎 **File Uploads**: Upload and manage files
- 🔔 **Real-time Updates**: WebSocket support for real-time events
- 🧩 **Plugins & Integrations**: Support for Mattermost plugins and integrations
- 🔍 **Search**: Comprehensive search capabilities
- 🛠️ **Admin Functions**: Administrative operations support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  mattermost_flutter: ^1.0.0
```

Then run:

```shellscript
flutter pub get
```

## Basic Usage

### Initialize the Client

```plaintext
import 'package:mattermost_flutter/mattermost_flutter.dart';

// Initialize the client
final client = MattermostClient(
  config: MattermostConfig(
    baseUrl: 'https://your-mattermost-server.com',
    enableDebugLogs: true,
  ),
);
```

### Authentication

```plaintext
// Login with username/email and password
try {
  await client.login(
    loginId: 'username_or_email',
    password: 'your_password',
  );
  print('Login successful!');
} catch (e) {
  print('Login failed: $e');
}

// Logout
await client.logout();
```

### Working with Users

```plaintext
// Get current user
final currentUser = await client.users.getMe();
print('Logged in as: ${currentUser.username}');

// Get user by ID
final user = await client.users.getUser('user_id');

// Update user
await client.users.updateUser(
  'user_id',
  UpdateUserRequest(
    firstName: 'New First Name',
    lastName: 'New Last Name',
  ),
);
```

### Working with Teams

```plaintext
// Get teams for user
final teams = await client.teams.getTeamsForUser('user_id');

// Create a team
final newTeam = await client.teams.createTeam(
  CreateTeamRequest(
    name: 'team-name',
    displayName: 'Team Display Name',
    type: 'O', // Open team
  ),
);
```

### Working with Channels

```plaintext
// Get channels for team
final channels = await client.channels.getChannelsForTeam('team_id');

// Create a channel
final newChannel = await client.channels.createChannel(
  CreateChannelRequest(
    teamId: 'team_id',
    name: 'channel-name',
    displayName: 'Channel Display Name',
    type: 'O', // Public channel
    purpose: 'Channel purpose',
    header: 'Channel header',
  ),
);

// Join a channel
await client.channels.addChannelMember('channel_id', 'user_id');
```

### Working with Posts

```plaintext
// Create a post
final post = await client.posts.createPost(
  CreatePostRequest(
    channelId: 'channel_id',
    message: 'Hello, Mattermost!',
  ),
);

// Get posts for a channel
final posts = await client.posts.getPostsForChannel(
  'channel_id',
  perPage: 30,
);

// Add a reaction to a post
await client.posts.addReaction(
  ReactionRequest(
    userId: 'user_id',
    postId: 'post_id',
    emojiName: '+1',
  ),
);
```

### Using WebSockets for Real-time Updates

```plaintext
// Connect to WebSocket
client.webSocket.connect();

// Listen for events
client.webSocket.events.listen((event) {
  if (event['event'] == 'posted') {
    print('New message posted!');
    // Handle new message
  }
});

// Disconnect WebSocket
client.webSocket.disconnect();
```

## API Documentation

The package provides access to all Mattermost API endpoints through the following classes:

- `UsersApi`: User management
- `TeamsApi`: Team management
- `ChannelsApi`: Channel operations
- `PostsApi`: Post (message) operations
- `FilesApi`: File upload and management
- `SystemApi`: System configuration
- `WebhooksApi`: Webhook management
- `PreferencesApi`: User preferences
- `StatusApi`: User status
- `EmojisApi`: Custom emoji management
- `ComplianceApi`: Compliance reports
- `ClustersApi`: Cluster management
- `LDAPApi`: LDAP integration
- `OAuthApi`: OAuth app management
- `ElasticsearchApi`: Elasticsearch configuration
- `PluginsApi`: Plugin management
- `RolesApi`: Role management
- `SchemesApi`: Scheme management
- `IntegrationsApi`: Integration management
- `BrandApi`: Brand image management
- `CommandsApi`: Slash command management
- `GroupsApi`: Group management
- `BotsApi`: Bot account management
- `JobsApi`: Background job management
- `DataRetentionApi`: Data retention policies
- `ExportsApi`: Data export
- `ImportsApi`: Data import
- `SAMLApi`: SAML configuration
- `PermissionsApi`: Permission management
- `SharedChannelsApi`: Shared channel management
- `CloudApi`: Cloud service management

## Configuration Options

The `MattermostConfig` class provides several configuration options:

```plaintext
final config = MattermostConfig(
  baseUrl: 'https://your-mattermost-server.com',
  enableDebugLogs: true,
  timeout: const Duration(seconds: 30),
  validateCertificate: true,
  userAgent: 'MyMattermostApp/1.0',
);
```

## Complete Example

Here's a more complete example showing how to build a simple Mattermost client:

```plaintext
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mattermost Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mattermost Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _serverController,
              decoration: InputDecoration(labelText: 'Server URL'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username or Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final client = MattermostClient(
        config: MattermostConfig(
          baseUrl: _serverController.text,
          enableDebugLogs: true,
        ),
      );

      await client.login(
        loginId: _usernameController.text,
        password: _passwordController.text,
      );

      final currentUser = await client.users.getMe();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelListScreen(
            client: client,
            currentUser: currentUser,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class ChannelListScreen extends StatefulWidget {
  final MattermostClient client;
  final User currentUser;

  ChannelListScreen({required this.client, required this.currentUser});

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  List<Team> _teams = [];
  List<Channel> _channels = [];
  Team? _selectedTeam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await widget.client.teams.getTeamsForUser(widget.currentUser.id);
      setState(() {
        _teams = teams;
        if (teams.isNotEmpty) {
          _selectedTeam = teams.first;
          _loadChannels(_selectedTeam!.id);
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      print('Error loading teams: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChannels(String teamId) async {
    setState(() => _isLoading = true);
    try {
      final channels = await widget.client.channels.getChannelsForUser(
        widget.currentUser.id,
        teamId,
      );
      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading channels: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTeam?.displayName ?? 'Channels'),
        actions: [
          PopupMenuButton<Team>(
            onSelected: (team) {
              setState(() => _selectedTeam = team);
              _loadChannels(team.id);
            },
            itemBuilder: (context) => _teams
                .map((team) => PopupMenuItem<Team>(
                      value: team,
                      child: Text(team.displayName),
                    ))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _channels.length,
              itemBuilder: (context, index) {
                final channel = _channels[index];
                return ListTile(
                  leading: Icon(
                    channel.type == 'O' ? Icons.tag : Icons.lock,
                  ),
                  title: Text(channel.displayName),
                  subtitle: Text(channel.purpose),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChannelScreen(
                          client: widget.client,
                          currentUser: widget.currentUser,
                          channel: channel,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ChannelScreen extends StatefulWidget {
  final MattermostClient client;
  final User currentUser;
  final Channel channel;

  ChannelScreen({
    required this.client,
    required this.currentUser,
    required this.channel,
  });

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final _messageController = TextEditingController();
  List<Post> _posts = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _setupWebSocket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _setupWebSocket() {
    _subscription = widget.client.webSocket.events.listen((event) {
      if (event['event'] == 'posted' &&
          event['data']['channel_id'] == widget.channel.id) {
        _loadPosts();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final postList = await widget.client.posts.getPostsForChannel(
        widget.channel.id,
        perPage: 50,
      );

      setState(() {
        _posts = postList.posts.values.toList()
          ..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    try {
      await widget.client.posts.createPost(
        CreatePostRequest(
          channelId: widget.channel.id,
          message: message,
        ),
      );
      _loadPosts();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.displayName)),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return ListTile(
                        title: Text(post.message),
                        subtitle: Text('User ID: ${post.userId}'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Error Handling

The package provides detailed error information when API calls fail:

```plaintext
try {
  await client.login(
    loginId: 'username_or_email',
    password: 'wrong_password',
  );
} catch (e) {
  if (e is MattermostApiException) {
    print('Status code: ${e.statusCode}');
    print('Error message: ${e.message}');
    print('Error details: ${e.details}');
  } else {
    print('Unexpected error: $e');
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Contributors

- [phatdat-dev](https://github.com/phatdat-dev)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Mattermost API Reference](https://api.mattermost.com/)
- [Mattermost Documentation](https://docs.mattermost.com/)
