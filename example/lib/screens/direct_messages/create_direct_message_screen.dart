import 'package:flutter/material.dart';

class CreateDirectMessageScreen extends StatefulWidget {
  const CreateDirectMessageScreen({super.key});

  @override
  State<CreateDirectMessageScreen> createState() => _CreateDirectMessageScreenState();
}

class _CreateDirectMessageScreenState extends State<CreateDirectMessageScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final List<Map<String, dynamic>> _selectedUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load users from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _users = [
        {
          'id': '1',
          'username': 'john.doe',
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john.doe@example.com',
          'status': 'online',
          'position': 'Software Engineer',
        },
        {
          'id': '2',
          'username': 'jane.smith',
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane.smith@example.com',
          'status': 'away',
          'position': 'Product Manager',
        },
        {
          'id': '3',
          'username': 'bob.wilson',
          'first_name': 'Bob',
          'last_name': 'Wilson',
          'email': 'bob.wilson@example.com',
          'status': 'offline',
          'position': 'Designer',
        },
        {
          'id': '4',
          'username': 'alice.brown',
          'first_name': 'Alice',
          'last_name': 'Brown',
          'email': 'alice.brown@example.com',
          'status': 'dnd',
          'position': 'DevOps Engineer',
        },
      ];

      _filteredUsers = List.from(_users);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        if (_selectedUsers.any((selected) => selected['id'] == user['id'])) {
          return false; // Hide already selected users
        }

        final name = '${user['first_name']} ${user['last_name']}'.toLowerCase();
        final username = user['username'].toLowerCase();
        final email = user['email'].toLowerCase();
        return name.contains(query) || username.contains(query) || email.contains(query);
      }).toList();
    });
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      final isSelected = _selectedUsers.any((selected) => selected['id'] == user['id']);
      if (isSelected) {
        _selectedUsers.removeWhere((selected) => selected['id'] == user['id']);
      } else {
        _selectedUsers.add(user);
      }
      _filterUsers(); // Refresh the filtered list
    });
  }

  void _createDirectMessage() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Create direct message via API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        if (_selectedUsers.length == 1) {
          // Direct message
          Navigator.pop(context, {
            'type': 'direct',
            'users': _selectedUsers,
          });
        } else {
          // Group message
          Navigator.pop(context, {
            'type': 'group',
            'users': _selectedUsers,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'dnd':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedUsers.length > 1 ? 'New Group Message' : 'New Direct Message'),
        actions: [
          TextButton(
            onPressed: _selectedUsers.isEmpty || _isLoading ? null : _createDirectMessage,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Start'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for people...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),

          // Selected users
          if (_selectedUsers.isNotEmpty) ...[
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected (${_selectedUsers.length})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    child: Text(
                                      (user['first_name']?[0] ?? user['username'][0]).toUpperCase(),
                                    ),
                                  ),
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: GestureDetector(
                                      onTap: () => _toggleUserSelection(user),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  user['first_name'] ?? user['username'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
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
                          _searchController.text.isNotEmpty ? 'No users found' : 'Search to find people',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try searching by name, username, or email',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected = _selectedUsers.any((selected) => selected['id'] == user['id']);

                      return ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              child: Text(
                                (user['first_name']?[0] ?? user['username'][0]).toUpperCase(),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(user['status']),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          '${user['first_name']} ${user['last_name']}'.trim().isEmpty
                              ? '@${user['username']}'
                              : '${user['first_name']} ${user['last_name']}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${user['username']}'),
                            if (user['position']?.isNotEmpty == true)
                              Text(
                                user['position'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const Icon(Icons.radio_button_unchecked),
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
