import 'package:flutter/material.dart';

class ReactionsScreen extends StatefulWidget {
  final String? postId;
  final Map<String, List<String>>? reactions;

  const ReactionsScreen({
    super.key,
    this.postId,
    this.reactions,
  });

  @override
  State<ReactionsScreen> createState() => _ReactionsScreenState();
}

class _ReactionsScreenState extends State<ReactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _reactionTypes = [];
  Map<String, List<Map<String, dynamic>>> _reactionsByType = {};

  @override
  void initState() {
    super.initState();
    _initializeReactions();
    _tabController = TabController(length: _reactionTypes.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeReactions() {
    // Sample reaction data
    _reactionsByType = {
      '👍': [
        {'userId': '1', 'username': 'john.doe', 'displayName': 'John Doe'},
        {'userId': '2', 'username': 'jane.smith', 'displayName': 'Jane Smith'},
        {'userId': '3', 'username': 'bob.wilson', 'displayName': 'Bob Wilson'},
      ],
      '❤️': [
        {'userId': '4', 'username': 'alice.brown', 'displayName': 'Alice Brown'},
        {'userId': '5', 'username': 'charlie.davis', 'displayName': 'Charlie Davis'},
      ],
      '😄': [
        {'userId': '6', 'username': 'david.lee', 'displayName': 'David Lee'},
      ],
      '😮': [
        {'userId': '7', 'username': 'eva.martinez', 'displayName': 'Eva Martinez'},
        {'userId': '8', 'username': 'frank.taylor', 'displayName': 'Frank Taylor'},
        {'userId': '9', 'username': 'grace.white', 'displayName': 'Grace White'},
      ],
    };

    _reactionTypes = _reactionsByType.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Reactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Tab bar
          if (_reactionTypes.isNotEmpty) ...[
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group, size: 18),
                      const SizedBox(width: 4),
                      Text('All (${_getTotalReactionCount()})'),
                    ],
                  ),
                ),
                ..._reactionTypes.map(
                  (emoji) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text('${_reactionsByType[emoji]?.length ?? 0}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Tab content
          Flexible(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllReactionsTab(),
                  ..._reactionTypes.map((emoji) => _buildReactionTab(emoji)),
                ],
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildAllReactionsTab() {
    List<Map<String, dynamic>> allReactions = [];
    _reactionsByType.forEach((emoji, users) {
      for (var user in users) {
        allReactions.add({
          ...user,
          'emoji': emoji,
        });
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: allReactions.length,
      itemBuilder: (context, index) {
        final reaction = allReactions[index];
        return _buildUserReactionTile(
          user: reaction,
          emoji: reaction['emoji'],
        );
      },
    );
  }

  Widget _buildReactionTab(String emoji) {
    final users = _reactionsByType[emoji] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserReactionTile(
          user: user,
          emoji: emoji,
        );
      },
    );
  }

  Widget _buildUserReactionTile({
    required Map<String, dynamic> user,
    required String emoji,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          user['displayName']?.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(user['displayName'] ?? user['username']),
      subtitle: Text('@${user['username']}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      onTap: () {
        // Navigate to user profile
        _showUserProfile(user);
      },
    );
  }

  int _getTotalReactionCount() {
    return _reactionsByType.values.map((users) => users.length).fold(0, (sum, count) => sum + count);
  }

  void _showUserProfile(Map<String, dynamic> user) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening profile for ${user['displayName']}')),
    );
  }
}
