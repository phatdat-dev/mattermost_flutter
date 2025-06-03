# Global Threads Screen Implementation

This document describes the implementation of the `GlobalThreadsScreen` widget, which provides a comprehensive interface for managing Mattermost threads with real API integration.

## Overview

The `GlobalThreadsScreen` replaces mock data with actual Mattermost API calls to provide real thread functionality including:

- **Real API Integration**: Fetches threads from actual Mattermost servers
- **Thread Following**: Follow/unfollow threads using preferences API
- **Read State Tracking**: Mark threads as read with persistent state
- **Real-time Updates**: WebSocket integration for live thread updates
- **Thread Filtering**: Filter threads by unread, following, or all
- **Modern UI**: Clean, responsive interface with Material Design 3

## Features

### ✅ Completed Features

1. **API Integration**
   - Fetches teams, channels, and posts from Mattermost API
   - Uses `MTeamsApi`, `MChannelsApi`, `MPostsApi`, `MUsersApi`, and `MPreferencesApi`
   - Proper error handling and loading states

2. **Thread Management**
   - Identifies threaded conversations using `rootId` and `parentId`
   - Loads thread participants and reply counts
   - Tracks unread replies and mentions

3. **Following System**
   - Toggle follow/unfollow using preferences API
   - Persistent follow state across sessions
   - Visual indicators for followed threads

4. **Read State Management**
   - Mark individual threads as read
   - Bulk "mark all as read" functionality
   - Read state persistence via preferences API

5. **Real-time Updates**
   - WebSocket integration for live updates
   - Automatic thread refresh on new posts
   - Event handling for `posted`, `thread_updated`, `post_updated`

6. **Filtering**
   - Unread threads filter
   - Following threads filter
   - All threads view
   - Dynamic counts for each filter

7. **Modern UI**
   - Material Design 3 components
   - Responsive design for various screen sizes
   - Smooth animations and transitions
   - Proper dark/light theme support

## File Structure

```
lib/screens/messages/
├── global_threads_screen.dart     # Main implementation
└── ...

example/lib/
├── global_threads_demo.dart       # Standalone demo app
├── test_global_threads.dart       # Navigation test helper
└── ...
```

## Usage

### Basic Usage

```dart
import 'package:mattermost_flutter/mattermost_flutter.dart';
import 'package:mattermost_example/screens/messages/global_threads_screen.dart';

// Navigate to GlobalThreadsScreen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => GlobalThreadsScreen(
      client: mattermostClient,    // Required: MattermostClient instance
      currentUser: currentUser,    // Required: MUser instance
    ),
  ),
);
```

### With Navigation Arguments

```dart
// Using with named routes (requires route configuration)
Navigator.of(context).pushNamed(
  '/global_threads',
  arguments: DashboardArguments(
    client: client,
    currentUser: currentUser,
  ),
);
```

### Required Parameters

The `GlobalThreadsScreen` requires two parameters:

1. **`client`** (`MattermostClient`): An authenticated Mattermost client instance
2. **`currentUser`** (`MUser`): The currently logged-in user

## Implementation Details

### API Calls Used

The screen makes the following API calls:

```dart
// Get teams for user
final teams = await client.teams.getTeamsForUser(userId);

// Get channels for team
final channels = await client.channels.getChannelsForUser(userId, teamId);

// Get posts for channel
final posts = await client.posts.getPostsForChannel(channelId, perPage: 50);

// Get thread details
final thread = await client.posts.getPostThread(postId);

// Get user information
final user = await client.users.getUser(userId);

// Manage preferences (follow/read state)
await client.preferences.saveUserPreferences(userId, [preference]);
await client.preferences.deleteUserPreferences(userId, [preference]);
```

### WebSocket Integration

Real-time updates are handled via WebSocket:

```dart
widget.client.webSocket.events.listen((event) {
  if (event['event'] == 'posted' || 
      event['event'] == 'thread_updated' ||
      event['event'] == 'post_updated') {
    _loadThreads(); // Refresh threads
  }
});
```

### Data Structure

Threads are represented as:

```dart
{
  'id': 'post_id',
  'original_post': {
    'id': 'post_id',
    'message': 'Thread message',
    'user': {'username': 'user', 'first_name': 'First', 'last_name': 'Last'},
    'created_at': DateTime,
  },
  'channel': {
    'id': 'channel_id',
    'display_name': 'Channel Name',
    'type': 'O', // O=public, P=private
  },
  'reply_count': 5,
  'participants': [/* user objects */],
  'last_reply_at': DateTime,
  'unread_replies': 2,
  'unread_mentions': 1,
  'is_following': true,
}
```

## Running the Demo

You can run the standalone demo to test the GlobalThreadsScreen:

```bash
# In the example directory
flutter run lib/global_threads_demo.dart
```

The demo creates mock client and user instances for testing purposes.

## Performance Considerations

### Current Implementation

- Loads all teams and channels for the user
- Fetches up to 50 posts per channel
- Identifies threads by checking for replies
- May be slow for users in many channels

### Potential Optimizations

1. **Pagination**: Implement pagination for large datasets
2. **Caching**: Add local caching for thread data
3. **Lazy Loading**: Load thread details on demand
4. **Background Processing**: Use isolates for data processing
5. **API Optimization**: Use more specific endpoints when available

## Integration with Main App

To integrate with your main Mattermost app:

1. **Add Route Configuration**:
   ```dart
   case Screens.globalThreads:
     final args = settings.arguments as DashboardArguments?;
     return MaterialPageRoute(
       builder: (_) => GlobalThreadsScreen(
         client: args!.client,
         currentUser: args.currentUser,
       ),
     );
   ```

2. **Add Navigation from Dashboard**:
   ```dart
   // In your dashboard or main navigation
   onTap: () {
     Navigator.of(context).pushNamed(
       Screens.globalThreads,
       arguments: DashboardArguments(
         client: widget.client,
         currentUser: widget.currentUser,
       ),
     );
   }
   ```

3. **Add to Bottom Navigation or Menu**:
   ```dart
   BottomNavigationBarItem(
     icon: Icon(Icons.forum),
     label: 'Threads',
   ),
   ```

## Error Handling

The implementation includes comprehensive error handling:

- **Network Errors**: Graceful handling of API failures
- **Loading States**: Proper loading indicators
- **Empty States**: User-friendly empty state messages
- **Permission Errors**: Handling of access denied scenarios

## Testing

### Manual Testing

1. **Test with Real Server**: Connect to actual Mattermost instance
2. **Test Thread Actions**: Follow/unfollow, mark as read
3. **Test Filtering**: Verify filter functionality
4. **Test Real-time**: Verify WebSocket updates work

### Unit Testing

Create unit tests for:
- Thread loading logic
- Filtering functionality
- API error handling
- WebSocket event processing

## Future Enhancements

### Planned Improvements

1. **Thread Detail View**: Dedicated screen for viewing full thread
2. **Thread Creation**: Allow starting new threads
3. **Thread Search**: Search within threads
4. **Notification Integration**: Push notifications for thread updates
5. **Offline Support**: Cache threads for offline viewing
6. **Performance Optimization**: Implement caching and pagination

### UI Enhancements

1. **Pull-to-Refresh**: Gesture-based refresh
2. **Swipe Actions**: Swipe to follow/mark as read
3. **Rich Media Support**: Display images and files in threads
4. **Emoji Reactions**: Show and manage reactions
5. **Thread Previews**: Show thread content preview

## Contributing

When contributing to the GlobalThreadsScreen:

1. **Follow Flutter Best Practices**: Use proper state management
2. **Maintain API Integration**: Keep real API calls, avoid mock data
3. **Test Thoroughly**: Test with real Mattermost servers
4. **Document Changes**: Update this README with new features
5. **Handle Errors Gracefully**: Add proper error handling for new features

## Known Issues

1. **Performance**: May be slow with many channels (optimization needed)
2. **Thread Definition**: Currently identifies threads by checking replies (could use better API endpoint)
3. **Read State**: Simplified read state tracking (could be more sophisticated)

## Dependencies

The GlobalThreadsScreen depends on:

- `mattermost_flutter`: Core Mattermost API package
- `flutter/material.dart`: Material Design components
- `dart:async`: For async operations and WebSocket handling

## Version History

- **v1.0**: Initial implementation with real API integration
- **Current**: Full feature set with WebSocket support and preferences integration
