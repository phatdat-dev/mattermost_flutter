import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              AppRoutes.currentUser!.username.isNotEmpty ? AppRoutes.currentUser!.username[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${AppRoutes.currentUser!.firstName} ${AppRoutes.currentUser!.lastName}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('@${AppRoutes.currentUser!.username}', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Text(AppRoutes.currentUser!.email, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
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
