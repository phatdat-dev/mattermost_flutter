import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class SearchScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MTeam? team;

  const SearchScreen({
    super.key,
    required this.client,
    required this.currentUser,
    this.team,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  List<MPost> _messageResults = [];
  List<MChannel> _channelResults = [];
  List<MUser> _userResults = [];
  List<MFileInfo> _fileResults = [];

  bool _isSearching = false;
  String _currentQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _messageResults.clear();
        _channelResults.clear();
        _userResults.clear();
        _fileResults.clear();
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentQuery = query;
      _errorMessage = null;
    });

    try {
      // Search in parallel for better performance
      final futures = await Future.wait([
        _searchMessages(query),
        _searchChannels(query),
        _searchUsers(query),
        _searchFiles(query),
      ]);

      if (mounted) {
        setState(() {
          _messageResults = futures[0] as List<MPost>;
          _channelResults = futures[1] as List<MChannel>;
          _userResults = futures[2] as List<MUser>;
          _fileResults = futures[3] as List<MFileInfo>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Search failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<List<MPost>> _searchMessages(String query) async {
    try {
      final teamId = widget.team?.id ?? '';

      final results = await widget.client.posts.searchPosts(
        teamId,
        terms: query,
        isOrSearch: false,
        timeZoneOffset: DateTime.now().timeZoneOffset.inSeconds,
        includeDeletedChannels: false,
        page: 0,
        perPage: 20,
      );
      return results.posts.values.toList();
    } catch (e) {
      debugPrint('Message search error: $e');
      return [];
    }
  }

  Future<List<MChannel>> _searchChannels(String query) async {
    try {
      final teamId = widget.team?.id ?? '';
      if (teamId.isEmpty) return [];

      final results = await widget.client.channels.searchChannels(
        teamId,
        term: query,
      );
      return results;
    } catch (e) {
      debugPrint('Channel search error: $e');
      return [];
    }
  }

  Future<List<MUser>> _searchUsers(String query) async {
    try {
      final results = await widget.client.users.searchUsers(
        term: query,
        limit: 20,
      );
      return results;
    } catch (e) {
      debugPrint('User search error: $e');
      return [];
    }
  }

  Future<List<MFileInfo>> _searchFiles(String query) async {
    try {
      // In a real implementation, search files by name
      await Future.delayed(const Duration(milliseconds: 500));
      return []; // Placeholder
    } catch (e) {
      debugPrint('File search error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search messages, channels, people...',
            border: InputBorder.none,
            suffixIcon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onSubmitted: _performSearch,
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.message),
              text: 'Messages',
              child: _messageResults.isNotEmpty
                  ? Badge(
                      label: Text('${_messageResults.length}'),
                      child: const Tab(icon: Icon(Icons.message), text: 'Messages'),
                    )
                  : null,
            ),
            Tab(
              icon: const Icon(Icons.tag),
              text: 'Channels',
              child: _channelResults.isNotEmpty
                  ? Badge(
                      label: Text('${_channelResults.length}'),
                      child: const Tab(icon: Icon(Icons.tag), text: 'Channels'),
                    )
                  : null,
            ),
            Tab(
              icon: const Icon(Icons.people),
              text: 'People',
              child: _userResults.isNotEmpty
                  ? Badge(
                      label: Text('${_userResults.length}'),
                      child: const Tab(icon: Icon(Icons.people), text: 'People'),
                    )
                  : null,
            ),
            Tab(
              icon: const Icon(Icons.attach_file),
              text: 'Files',
              child: _fileResults.isNotEmpty
                  ? Badge(
                      label: Text('${_fileResults.length}'),
                      child: const Tab(icon: Icon(Icons.attach_file), text: 'Files'),
                    )
                  : null,
            ),
          ],
        ),
      ),
      body: _currentQuery.isEmpty
          ? _buildSearchSuggestions()
          : _errorMessage != null
          ? _buildErrorView()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMessageResults(),
                _buildChannelResults(),
                _buildUserResults(),
                _buildFileResults(),
              ],
            ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Tips',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchTip('from:username', 'Find messages from a specific user'),
                  _buildSearchTip('in:channel-name', 'Search within a specific channel'),
                  _buildSearchTip('before:2023-12-31', 'Find messages before a date'),
                  _buildSearchTip('after:2023-01-01', 'Find messages after a date'),
                  _buildSearchTip('"exact phrase"', 'Search for an exact phrase'),
                  _buildSearchTip('has:attachments', 'Find messages with file attachments'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: Implement recent searches from local storage
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No recent searches',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTip(String syntax, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              syntax,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _performSearch(_currentQuery),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageResults() {
    if (_messageResults.isEmpty) {
      return _buildEmptyResults('No messages found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messageResults.length,
      itemBuilder: (context, index) {
        final post = _messageResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.message),
            title: Text(
              post.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Channel • ${_formatTimestamp(post.createAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message navigation coming soon')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChannelResults() {
    if (_channelResults.isEmpty) {
      return _buildEmptyResults('No channels found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _channelResults.length,
      itemBuilder: (context, index) {
        final channel = _channelResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              channel.type == 'O' ? Icons.tag : Icons.lock,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(channel.displayName),
            subtitle: channel.purpose.isNotEmpty
                ? Text(
                    channel.purpose,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to channel
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Channel navigation coming soon')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) {
      return _buildEmptyResults('No users found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.username),
            subtitle: Text('${user.firstName} ${user.lastName}'.trim()),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to user profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User profile navigation coming soon')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFileResults() {
    if (_fileResults.isEmpty) {
      return _buildEmptyResults('No files found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fileResults.length,
      itemBuilder: (context, index) {
        final file = _fileResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.attach_file),
            title: Text(file.name),
            subtitle: Text('${file.size} bytes • ${file.mimeType}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Open file viewer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File viewer coming soon')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyResults(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Unknown time';
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
