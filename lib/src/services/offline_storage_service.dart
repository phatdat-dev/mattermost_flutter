/*
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import '../models/models.dart';

class OfflineStorageService {
  static const String _databaseName = 'mattermost_offline.db';
  static const int _databaseVersion = 1;
  
  // Table names
  static const String _tableUsers = 'users';
  static const String _tableTeams = 'teams';
  static const String _tableChannels = 'channels';
  static const String _tablePosts = 'posts';
  static const String _tablePreferences = 'preferences';
  static const String _tableFiles = 'files';
  static const String _tableSyncQueue = 'sync_queue';
  
  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $_tableUsers (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        nickname TEXT,
        position TEXT,
        roles TEXT,
        locale TEXT,
        timezone TEXT,
        data TEXT
      )
    ''');
    
    // Create teams table
    await db.execute('''
      CREATE TABLE $_tableTeams (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        display_name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        data TEXT
      )
    ''');
    
    // Create channels table
    await db.execute('''
      CREATE TABLE $_tableChannels (
        id TEXT PRIMARY KEY,
        team_id TEXT NOT NULL,
        name TEXT NOT NULL,
        display_name TEXT NOT NULL,
        type TEXT NOT NULL,
        header TEXT,
        purpose TEXT,
        last_post_at INTEGER,
        total_msg_count INTEGER,
        data TEXT,
        FOREIGN KEY (team_id) REFERENCES $_tableTeams (id) ON DELETE CASCADE
      )
    ''');
    
    // Create posts table
    await db.execute('''
      CREATE TABLE $_tablePosts (
        id TEXT PRIMARY KEY,
        channel_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        message TEXT NOT NULL,
        create_at INTEGER,
        update_at INTEGER,
        edit_at INTEGER,
        delete_at INTEGER,
        is_pinned INTEGER,
        root_id TEXT,
        parent_id TEXT,
        data TEXT,
        FOREIGN KEY (channel_id) REFERENCES $_tableChannels (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES $_tableUsers (id) ON DELETE CASCADE
      )
    ''');
    
    // Create preferences table
    await db.execute('''
      CREATE TABLE $_tablePreferences (
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        value TEXT NOT NULL,
        PRIMARY KEY (user_id, category, name),
        FOREIGN KEY (user_id) REFERENCES $_tableUsers (id) ON DELETE CASCADE
      )
    ''');
    
    // Create files table
    await db.execute('''
      CREATE TABLE $_tableFiles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        post_id TEXT,
        name TEXT NOT NULL,
        extension TEXT,
        size INTEGER,
        mime_type TEXT,
        local_path TEXT,
        remote_path TEXT,
        data TEXT,
        FOREIGN KEY (user_id) REFERENCES $_tableUsers (id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES $_tablePosts (id) ON DELETE CASCADE
      )
    ''');
    
    // Create sync queue table
    await db.execute('''
      CREATE TABLE $_tableSyncQueue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retries INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending'
      )
    ''');
    
    // Create indexes
    await db.execute('CREATE INDEX idx_posts_channel_id ON $_tablePosts (channel_id)');
    await db.execute('CREATE INDEX idx_posts_user_id ON $_tablePosts (user_id)');
    await db.execute('CREATE INDEX idx_posts_create_at ON $_tablePosts (create_at)');
    await db.execute('CREATE INDEX idx_channels_team_id ON $_tableChannels (team_id)');
    await db.execute('CREATE INDEX idx_files_post_id ON $_tableFiles (post_id)');
  }
  
  // User methods
  Future<void> saveUser(MUser user) async {
    final db = await database;
    await db.insert(
      _tableUsers,
      {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'nickname': user.nickname,
        'position': user.position,
        'roles': user.roles,
        'locale': user.locale,
        'timezone': user.timezone?.automaticTimezone,
        'data': jsonEncode(user.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<MUser?> getUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      _tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    final userData = jsonDecode(maps.first['data'] as String);
    return MUser.fromJson(userData);
  }
  
  // Team methods
  Future<void> saveTeam(MTeam team) async {
    final db = await database;
    await db.insert(
      _tableTeams,
      {
        'id': team.id,
        'name': team.name,
        'display_name': team.displayName,
        'description': team.description,
        'type': team.type,
        'data': jsonEncode(team.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<MTeam>> getTeams() async {
    final db = await database;
    final maps = await db.query(_tableTeams);
    
    return List.generate(maps.length, (i) {
      final teamData = jsonDecode(maps[i]['data'] as String);
      return MTeam.fromJson(teamData);
    });
  }
  
  // Channel methods
  Future<void> saveChannel(MChannel channel) async {
    final db = await database;
    await db.insert(
      _tableChannels,
      {
        'id': channel.id,
        'team_id': channel.teamId,
        'name': channel.name,
        'display_name': channel.displayName,
        'type': channel.type,
        'header': channel.header,
        'purpose': channel.purpose,
        'last_post_at': channel.lastPostAt,
        'total_msg_count': channel.totalMsgCount,
        'data': jsonEncode(channel.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<MChannel>> getChannelsForTeam(String teamId) async {
    final db = await database;
    final maps = await db.query(
      _tableChannels,
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
    
    return List.generate(maps.length, (i) {
      final channelData = jsonDecode(maps[i]['data'] as String);
      return MChannel.fromJson(channelData);
    });
  }
  
  // Post methods
  Future<void> savePost(MPost post) async {
    final db = await database;
    await db.insert(
      _tablePosts,
      {
        'id': post.id,
        'channel_id': post.channelId,
        'user_id': post.userId,
        'message': post.message,
        'create_at': post.createAt,
        'update_at': post.updateAt,
        'edit_at': post.editAt,
        'delete_at': post.deleteAt,
        'is_pinned': post.isPinned == true ? 1 : 0,
        'root_id': post.rootId,
        'parent_id': post.parentId,
        'data': jsonEncode(post.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<MPost>> getPostsForChannel(String channelId, {int limit = 50, int offset = 0}) async {
    final db = await database;
    final maps = await db.query(
      _tablePosts,
      where: 'channel_id = ? AND delete_at IS NULL',
      whereArgs: [channelId],
      orderBy: 'create_at DESC',
      limit: limit,
      offset: offset,
    );
    
    return List.generate(maps.length, (i) {
      final postData = jsonDecode(maps[i]['data'] as String);
      return MPost.fromJson(postData);
    });
  }
  
  Future<List<MPost>> getPostThread(String rootId) async {
    final db = await database;
    final maps = await db.query(
      _tablePosts,
      where: 'root_id = ? OR id = ? AND delete_at IS NULL',
      whereArgs: [rootId, rootId],
      orderBy: 'create_at ASC',
    );
    
    return List.generate(maps.length, (i) {
      final postData = jsonDecode(maps[i]['data'] as String);
      return MPost.fromJson(postData);
    });
  }
  
  // Preference methods
  Future<void> savePreference(String userId, String category, String name, String value) async {
    final db = await database;
    await db.insert(
      _tablePreferences,
      {
        'user_id': userId,
        'category': category,
        'name': name,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<MPreference>> getPreferences(String userId) async {
    final db = await database;
    final maps = await db.query(
      _tablePreferences,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    return List.generate(maps.length, (i) {
      return MPreference(
        userId: maps[i]['user_id'] as String,
        category: maps[i]['category'] as String,
        name: maps[i]['name'] as String,
        value: maps[i]['value'] as String,
      );
    });
  }
  
  // File methods
  Future<void> saveFile(String id, String userId, String? postId, String name, 
      String? extension, int? size, String? mimeType, String? localPath, String? remotePath, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      _tableFiles,
      {
        'id': id,
        'user_id': userId,
        'post_id': postId,
        'name': name,
        'extension': extension,
        'size': size,
        'mime_type': mimeType,
        'local_path': localPath,
        'remote_path': remotePath,
        'data': jsonEncode(data),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Map<String, dynamic>>> getFilesForPost(String postId) async {
    final db = await database;
    final maps = await db.query(
      _tableFiles,
      where: 'post_id = ?',
      whereArgs: [postId],
    );
    
    return List.generate(maps.length, (i) {
      final fileData = jsonDecode(maps[i]['data'] as String);
      return {
        'id': maps[i]['id'],
        'user_id': maps[i]['user_id'],
        'post_id': maps[i]['post_id'],
        'name': maps[i]['name'],
        'extension': maps[i]['extension'],
        'size': maps[i]['size'],
        'mime_type': maps[i]['mime_type'],
        'local_path': maps[i]['local_path'],
        'remote_path': maps[i]['remote_path'],
        'data': fileData,
      };
    });
  }
  
  // Sync queue methods
  Future<int> addToSyncQueue(String entityType, String entityId, String action, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      _tableSyncQueue,
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'data': jsonEncode(data),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'pending',
      },
    );
  }
  
  Future<List<Map<String, dynamic>>> getPendingSyncItems({int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      _tableSyncQueue,
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return {
        'id': maps[i]['id'],
        'entity_type': maps[i]['entity_type'],
        'entity_id': maps[i]['entity_id'],
        'action': maps[i]['action'],
        'data': jsonDecode(maps[i]['data'] as String),
        'created_at': maps[i]['created_at'],
        'retries': maps[i]['retries'],
        'status': maps[i]['status'],
      };
    });
  }
  
  Future<void> updateSyncItemStatus(int id, String status, {int? retries}) async {
    final db = await database;
    await db.update(
      _tableSyncQueue,
      {
        'status': status,
        if (retries != null) 'retries': retries,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Clear data methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tableUsers);
    await db.delete(_tableTeams);
    await db.delete(_tableChannels);
    await db.delete(_tablePosts);
    await db.delete(_tablePreferences);
    await db.delete(_tableFiles);
    await db.delete(_tableSyncQueue);
  }
  
  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(_tableUsers, where: 'id = ?', whereArgs: [userId]);
    await db.delete(_tablePreferences, where: 'user_id = ?', whereArgs: [userId]);
  }
  
  Future<void> clearTeamData(String teamId) async {
    final db = await database;
    await db.delete(_tableTeams, where: 'id = ?', whereArgs: [teamId]);
    
    // Get channels for this team
    final channels = await db.query(
      _tableChannels,
      columns: ['id'],
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
    
    // Delete posts for these channels
    for (final channel in channels) {
      final channelId = channel['id'] as String;
      await db.delete(_tablePosts, where: 'channel_id = ?', whereArgs: [channelId]);
    }
    
    // Delete channels
    await db.delete(_tableChannels, where: 'team_id = ?', whereArgs: [teamId]);
  }
  
  Future<void> clearChannelData(String channelId) async {
    final db = await database;
    await db.delete(_tableChannels, where: 'id = ?', whereArgs: [channelId]);
    await db.delete(_tablePosts, where: 'channel_id = ?', whereArgs: [channelId]);
  }
  
  // Database management
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
  
  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(dbPath);
    _database = null;
  }
}
*/