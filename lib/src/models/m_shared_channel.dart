/// Shared channel model
class MSharedChannel {
  final String id;
  final String teamId;
  final String home;
  final String displayName;
  final String name;
  final String purpose;
  final String header;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final String? creatorId;
  final String? remoteId;

  MSharedChannel({
    required this.id,
    required this.teamId,
    required this.home,
    required this.displayName,
    required this.name,
    required this.purpose,
    required this.header,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.creatorId,
    this.remoteId,
  });

  factory MSharedChannel.fromJson(Map<String, dynamic> json) {
    return MSharedChannel(
      id: json['id'] ?? '',
      teamId: json['team_id'] ?? '',
      home: json['home'] ?? '',
      displayName: json['display_name'] ?? '',
      name: json['name'] ?? '',
      purpose: json['purpose'] ?? '',
      header: json['header'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      creatorId: json['creator_id'],
      remoteId: json['remote_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'home': home,
      'display_name': displayName,
      'name': name,
      'purpose': purpose,
      'header': header,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (creatorId != null) 'creator_id': creatorId,
      if (remoteId != null) 'remote_id': remoteId,
    };
  }
}

/// Remote cluster model
class MRemoteCluster {
  final String remoteId;
  final String remoteTeamId;
  final String name;
  final String displayName;
  final String siteUrl;
  final int? createAt;
  final int? lastPingAt;
  final String? creatorId;

  MRemoteCluster({
    required this.remoteId,
    required this.remoteTeamId,
    required this.name,
    required this.displayName,
    required this.siteUrl,
    this.createAt,
    this.lastPingAt,
    this.creatorId,
  });

  factory MRemoteCluster.fromJson(Map<String, dynamic> json) {
    return MRemoteCluster(
      remoteId: json['remote_id'] ?? '',
      remoteTeamId: json['remote_team_id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      siteUrl: json['site_url'] ?? '',
      createAt: json['create_at'],
      lastPingAt: json['last_ping_at'],
      creatorId: json['creator_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remote_id': remoteId,
      'remote_team_id': remoteTeamId,
      'name': name,
      'display_name': displayName,
      'site_url': siteUrl,
      if (createAt != null) 'create_at': createAt,
      if (lastPingAt != null) 'last_ping_at': lastPingAt,
      if (creatorId != null) 'creator_id': creatorId,
    };
  }
}

/// Remote cluster invite model
class MRemoteClusterInvite {
  final String id;
  final String remoteId;
  final String remoteTeamId;
  final String name;
  final String displayName;
  final String siteUrl;
  final int? createAt;
  final int? expiresAt;
  final String? creatorId;
  final String? shareToken;
  final String? token;

  MRemoteClusterInvite({
    required this.id,
    required this.remoteId,
    required this.remoteTeamId,
    required this.name,
    required this.displayName,
    required this.siteUrl,
    this.createAt,
    this.expiresAt,
    this.creatorId,
    this.shareToken,
    this.token,
  });

  factory MRemoteClusterInvite.fromJson(Map<String, dynamic> json) {
    return MRemoteClusterInvite(
      id: json['id'] ?? '',
      remoteId: json['remote_id'] ?? '',
      remoteTeamId: json['remote_team_id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      siteUrl: json['site_url'] ?? '',
      createAt: json['create_at'],
      expiresAt: json['expires_at'],
      creatorId: json['creator_id'],
      shareToken: json['share_token'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remote_id': remoteId,
      'remote_team_id': remoteTeamId,
      'name': name,
      'display_name': displayName,
      'site_url': siteUrl,
      if (createAt != null) 'create_at': createAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (creatorId != null) 'creator_id': creatorId,
      if (shareToken != null) 'share_token': shareToken,
      if (token != null) 'token': token,
    };
  }
}

/// Create remote cluster invite request
class MCreateRemoteClusterInviteRequest {
  final String name;
  final String siteUrl;
  final int? expiresIn;

  MCreateRemoteClusterInviteRequest({
    required this.name,
    required this.siteUrl,
    this.expiresIn,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'site_url': siteUrl,
      if (expiresIn != null) 'expires_in': expiresIn,
    };
  }
}
