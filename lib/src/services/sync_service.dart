/*
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../mattermost_client.dart';
import 'offline_storage_service.dart';

class SyncService {
  final MattermostClient client;
  final OfflineStorageService storage;
  
  bool _isOnline = false;
  bool _isSyncing = false;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();
  
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  SyncService({required this.client, required this.storage});
  
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        // We're back online, start sync
        _syncStatusController.add(SyncStatus(isOnline: true, isSyncing: false, message: 'Back online'));
        syncNow();
      } else if (wasOnline && !_isOnline) {
        // We're offline now
        _syncStatusController.add(SyncStatus(isOnline: false, isSyncing: false, message: 'Offline mode'));
      }
    });
    
    // Start periodic sync
    _startPeriodicSync();
  }
  
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline && !_isSyncing) {
        syncNow();
      }
    });
  }
  
  Future<void> syncNow() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus(isOnline: _isOnline, isSyncing: true, message: 'Syncing...'));
    
    try {
      // Process outgoing changes first
      await _processOutgoingChanges();
      
      // Then fetch incoming changes
      await _fetchIncomingChanges();
      
      _syncStatusController.add(SyncStatus(isOnline: _isOnline, isSyncing: false, message: 'Sync completed'));
    } catch (e) {
      debugPrint('Sync error: $e');
      _syncStatusController.add(SyncStatus(
        isOnline: _isOnline, 
        isSyncing: false, 
        message: 'Sync failed: ${e.toString()}',
        error: e,
      ));
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> _processOutgoingChanges() async {
    if (!_isOnline) return;
    
    final pendingItems = await storage.getPendingSyncItems(limit: 50);
    
    for (final item in pendingItems) {
      try {
        final id = item['id'] as int;
        final entityType = item['entity_type'] as String;
        final action = item['action'] as String;
        final data = item['data'] as Map<String, dynamic>;
        
        switch (entityType) {
          case 'post':
            await _syncPost(id, action, data);
            break;
          case 'channel':
            await _syncChannel(id, action, data);
            break;
          case 'preference':
            await _syncPreference(id, action, data);
            break;
          case 'reaction':
            await _syncReaction(id, action, data);
            break;
          default:
            // Unknown entity type, mark as failed
            await storage.updateSyncItemStatus(id, 'failed');
        }
      } catch (e) {
        debugPrint('Error processing sync item: $e');
        
        // Update retry count and status
        final id = item['id'] as int;
        final retries = (item['retries'] as int) + 1;
        
        if (retries >= 5) {
          await storage.updateSyncItemStatus(id, 'failed');
        } else {
          await storage.updateSyncItemStatus(id, 'pending', retries: retries);
        }
      }
    }
  }
  
  Future<void> _syncPost(int id, String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'create':
        final post = await client.posts.createPost(
          channelId: data['channel_id'],
          message: data['message'],
          rootId: data['root_id'],
          fileIds: data['file_ids']?.cast<String>(),
        );
        
        // Update local storage with server response
        await storage.savePost(post);
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      case 'update':
        final post = await client.posts.updatePost(
          id: data['id'],
          message: data['message'],
          isPinned: data['is_pinned'],
        );
        
        // Update local storage with server response
        await storage.savePost(post);
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      case 'delete':
        await client.posts.deletePost(data['id']);
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      default:
        await storage.updateSyncItemStatus(id, 'failed');
    }
  }
  
  Future<void> _syncChannel(int id, String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'create':
        final channel = await client.channels.createChannel(
          teamId: data['team_id'],
          name: data['name'],
          displayName: data['display_name'],
          type: data['type'],
          purpose: data['purpose'],
          header: data['header'],
        );
        
        // Update local storage with server response
        await storage.saveChannel(channel);
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      case 'update':
        final channel = await client.channels.updateChannel(
          data['id'],
          name: data['name'],
          displayName: data['display_name'],
          purpose: data['purpose'],
          header: data['header'],
        );
        
        // Update local storage with server response
        await storage.saveChannel(channel);
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      case 'delete':
        await client.channels.deleteChannel(data['id']);
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      default:
        await storage.updateSyncItemStatus(id, 'failed');
    }
  }
  
  Future<void> _syncPreference(int id, String action, Map<String, dynamic> data) async {
    if (action == 'save') {
      await client.preferences.savePreferences([
        MPreference(
          userId: data['user_id'],
          category: data['category'],
          name: data['name'],
          value: data['value'],
        ),
      ]);
      
      await storage.updateSyncItemStatus(id, 'completed');
    } else {
      await storage.updateSyncItemStatus(id, 'failed');
    }
  }
  
  Future<void> _syncReaction(int id, String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'add':
        await client.posts.addReaction(
          userId: data['user_id'],
          postId: data['post_id'],
          emojiName: data['emoji_name'],
        );
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      case 'remove':
        await client.posts.removeReaction(
          data['user_id'],
          data['post_id'],
          data['emoji_name'],
        );
        await storage.updateSyncItemStatus(id, 'completed');
        break;
        
      default:
        await storage.updateSyncItemStatus(id, 'failed');
    }
  }
  
  Future<void> _fetchIncomingChanges() async {
    if (!_isOnline) return;
    
    // Get current user
    final currentUser = await client.users.getMe();
    await storage.saveUser(currentUser);
    
    // Get teams
    final teams = await client.teams.getTeamsForUser(currentUser.id);
    for (final team in teams) {
      await storage.saveTeam(team);
      
      // Get channels for team
      final channels = await client.channels.getChannelsForUser(currentUser.id, team.id);
      for (final channel in channels) {
        await storage.saveChannel(channel);
        
        // Get recent posts for channel
        try {
          final posts = await client.posts.getPostsForChannel(channel.id, perPage: 30);
          for (final post in posts.posts.values) {
            await storage.savePost(post);
          }
        } catch (e) {
          debugPrint('Error fetching posts for channel ${channel.id}: $e');
        }
      }
    }
    
    // Get preferences
    try {
      final preferences = await client.preferences.getMyPreferences();
      for (final pref in preferences) {
        await storage.savePreference(pref.userId, pref.category, pref.name, pref.value);
      }
    } catch (e) {
      debugPrint('Error fetching preferences: $e');
    }
  }
  
  // Methods for adding items to sync queue
  
  Future<void> queueCreatePost(String channelId, String message, {String? rootId, List<String>? fileIds}) async {
    await storage.addToSyncQueue(
      'post',
      'temp_${DateTime.now().millisecondsSinceEpoch}',
      'create',
      {
        'channel_id': channelId,
        'message': message,
        'root_id': rootId,
        'file_ids': fileIds,
      },
    );
    
    if (_isOnline) {
      syncNow();
    }
  }
  
  Future<void> queueUpdatePost(String postId, String message, {bool? isPinned}) async {
    await storage.addToSyncQueue(
      'post',
      postId,
      'update',
      {
        'id': postId,
        'message': message,
        'is_pinned': isPinned,
      },
    );
    
    if (_isOnline) {
      syncNow();
    }
  }
  
  Future<void> queueDeletePost(String postId) async {
    await storage.addToSyncQueue(
      'post',
      postId,
      'delete',
      {
        'id': postId,
      },
    );
    
    if (_isOnline) {
      syncNow();
    }
  }
  
  Future<void> queueAddReaction(String userId, String postId, String emojiName) async {
    await storage.addToSyncQueue(
      'reaction',
      '${postId}_${emojiName}',
      'add',
      {
        'user_id': userId,
        'post_id': postId,
        'emoji_name': emojiName,
      },
    );
    
    if (_isOnline) {
      syncNow();
    }
  }
  
  Future<void> queueRemoveReaction(String userId, String postId, String emojiName) async {
    await storage.addToSyncQueue(
      'reaction',
      '${postId}_${emojiName}',
      'remove',
      {
        'user_id': userId,
        'post_id': postId,
        'emoji_name': emojiName,
      },
    );
    
    if (_isOnline) {
      syncNow();
    }
  }
  
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

class SyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final String message;
  final Object? error;
  
  SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    required this.message,
    this.error,
  });
}
*/