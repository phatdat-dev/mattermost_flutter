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

```dart
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

```dart
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

```dart
// Get current user
final currentUser = await client.users.getMe();
print('Logged in as: ${currentUser.username}');

// Get user by ID
final user = await client.users.getUser('user_id');

// Update user
await client.users.updateUser(
  'user_id',
  MUpdateUserRequest(
    firstName: 'New First Name',
    lastName: 'New Last Name',
  ),
);
```

### Working with Teams

```dart
// Get teams for user
final teams = await client.teams.getTeamsForUser('user_id');

// Create a team
final newTeam = await client.teams.createTeam(
  MCreateTeamRequest(
    name: 'team-name',
    displayName: 'Team Display Name',
    type: 'O', // Open team
  ),
);
```

### Working with Channels

```dart
// Get channels for team
final channels = await client.channels.getChannelsForTeam('team_id');

// Create a channel
final newChannel = await client.channels.createChannel(
  MCreateChannelRequest(
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

```dart
// Create a post
final post = await client.posts.createPost(
  MCreatePostRequest(
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
  MReactionRequest(
    userId: 'user_id',
    postId: 'post_id',
    emojiName: '+1',
  ),
);
```

### Using WebSockets for Real-time Updates

```dart
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

- `MUsersApi`: User management
- `MTeamsApi`: Team management
- `MChannelsApi`: Channel operations
- `MPostsApi`: Post (message) operations
- `MFilesApi`: File upload and management
- `MSystemApi`: System configuration
- `MWebhooksApi`: Webhook management
- `MPreferencesApi`: User preferences
- `MStatusApi`: User status
- `MEmojisApi`: Custom emoji management
- `MComplianceApi`: Compliance reports
- `MClustersApi`: Cluster management
- `MLDAPApi`: LDAP integration
- `MOAuthApi`: OAuth app management
- `MElasticsearchApi`: Elasticsearch configuration
- `MPluginsApi`: Plugin management
- `MRolesApi`: Role management
- `MSchemesApi`: Scheme management
- `MIntegrationsApi`: Integration management
- `MBrandApi`: Brand image management
- `MCommandsApi`: Slash command management
- `MGroupsApi`: Group management
- `MBotsApi`: Bot account management
- `MJobsApi`: Background job management
- `MDataRetentionApi`: Data retention policies
- `MExportsApi`: Data export
- `MImportsApi`: Data import
- `MSAMLApi`: SAML configuration
- `MPermissionsApi`: Permission management
- `MSharedChannelsApi`: Shared channel management
- `MCloudApi`: Cloud service management

## Configuration Options

The `MattermostConfig` class provides several configuration options:

```dart
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

check the `example` directory for a full Flutter app that demonstrates the usage of this package.
Click [here](https://github.com/phatdat-dev/mattermost_flutter/tree/master/example) to explore the example app.

## Error Handling

The package provides detailed error information when API calls fail:

```dart
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
