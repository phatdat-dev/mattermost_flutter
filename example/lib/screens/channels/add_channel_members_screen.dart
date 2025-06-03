import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';

class AddChannelMembersScreen extends StatefulWidget {
  final MChannel channel;

  const AddChannelMembersScreen({
    super.key,
    required this.channel,
  });

  @override
  State<AddChannelMembersScreen> createState() => _AddChannelMembersScreenState();
}

class _AddChannelMembersScreenState extends State<AddChannelMembersScreen> {
  final _searchController = TextEditingController();
  List<MUser> _searchResults = [];
  final List<MUser> _selectedUsers = [];
  List<MUser> _currentMembers = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCurrentMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentMembers() async {
    setState(() => _isLoading = true);

    try {
      final members = await AppRoutes.client.channels.getChannelMembers(widget.channel.id);
      final memberUsers = <MUser>[];

      for (final member in members) {
        try {
          final user = await AppRoutes.client.users.getUser(member.userId);
          memberUsers.add(user);
        } catch (e) {
          debugPrint('Failed to load user ${member.userId}: $e');
        }
      }

      setState(() {
        _currentMembers = memberUsers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load current members: $e';
      });
    } finally {
      setState(() => _isLoading = false);
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

    setState(() => _isSearching = true);

    try {
      final users = await AppRoutes.client.users.searchUsers(
        term: term,
        limit: 20,
      );

      // Filter out current members and already selected users
      final currentMemberIds = _currentMembers.map((u) => u.id).toSet();
      final selectedUserIds = _selectedUsers.map((u) => u.id).toSet();

      setState(() {
        _searchResults = users.where((user) => !currentMemberIds.contains(user.id) && !selectedUserIds.contains(user.id)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
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

  Future<void> _addSelectedMembers() async {
    if (_selectedUsers.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      for (final user in _selectedUsers) {
        await AppRoutes.client.channels.addChannelMember(
          widget.channel.id,
          userId: user.id,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${_selectedUsers.length} member(s) to ${widget.channel.displayName}')),
        );
        Navigator.of(context).pop(_selectedUsers);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add members: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _addSelectedMembers,
              child: Text('Add (${_selectedUsers.length})'),
            ),
        ],
      ),
      body: _isLoading && _currentMembers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Channel info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Icon(
                        widget.channel.type == 'O' ? Icons.tag : Icons.lock,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adding members to ${widget.channel.displayName}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_currentMembers.length} current member(s)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for users to add...',
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Selected users chip list
                if (_selectedUsers.isNotEmpty)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected (${_selectedUsers.length}):',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedUsers.length,
                            itemBuilder: (context, index) {
                              final user = _selectedUsers[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
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

                // Results list
                Expanded(
                  child: _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_errorMessage!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadCurrentMembers,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(child: Text('No users found'))
                      : _searchController.text.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            final isSelected = _selectedUsers.contains(user);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(user.username),
                              subtitle: Text('${user.firstName} ${user.lastName}'.trim()),
                              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.add_circle_outline),
                              onTap: () => _toggleUserSelection(user),
                            );
                          },
                        ),
                ),

                // Loading overlay
                if (_isLoading && _currentMembers.isNotEmpty)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for users to add',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a username, first name, or last name to find users',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_currentMembers.isNotEmpty) ...[
            Text(
              'Current members in ${widget.channel.displayName}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: Card(
                child: ListView.builder(
                  itemCount: _currentMembers.length,
                  itemBuilder: (context, index) {
                    final member = _currentMembers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Text(
                          member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(member.username),
                      subtitle: Text('${member.firstName} ${member.lastName}'.trim()),
                      dense: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
