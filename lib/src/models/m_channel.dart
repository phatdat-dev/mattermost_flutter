import 'm_notify_props.dart';

/// Channel model
class MChannel {
  final String id;
  final String name;
  final String displayName;
  final String purpose;
  final String header;
  final String type;
  final String teamId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final int? lastPostAt;
  final int? totalMsgCount;
  final int? extraUpdateAt;
  final String? creatorId;
  final String? schemeId;
  final String? policyId;

  MChannel({
    required this.id,
    required this.name,
    required this.displayName,
    this.purpose = '',
    this.header = '',
    required this.type,
    required this.teamId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.lastPostAt,
    this.totalMsgCount,
    this.extraUpdateAt,
    this.creatorId,
    this.schemeId,
    this.policyId,
  });

  factory MChannel.fromJson(Map<String, dynamic> json) {
    return MChannel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      purpose: json['purpose'] ?? '',
      header: json['header'] ?? '',
      type: json['type'] ?? '',
      teamId: json['team_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      lastPostAt: json['last_post_at'],
      totalMsgCount: json['total_msg_count'],
      extraUpdateAt: json['extra_update_at'],
      creatorId: json['creator_id'],
      schemeId: json['scheme_id'],
      policyId: json['policy_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'purpose': purpose,
      'header': header,
      'type': type,
      'team_id': teamId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (lastPostAt != null) 'last_post_at': lastPostAt,
      if (totalMsgCount != null) 'total_msg_count': totalMsgCount,
      if (extraUpdateAt != null) 'extra_update_at': extraUpdateAt,
      if (creatorId != null) 'creator_id': creatorId,
      if (schemeId != null) 'scheme_id': schemeId,
      if (policyId != null) 'policy_id': policyId,
    };
  }
}

/// Channel member model
class MChannelMember {
  final String channelId;
  final String userId;
  final String roles;
  final int? lastViewedAt;
  final int? msgCount;
  final int? mentionCount;
  final MChannelNotifyProps? notifyProps;
  final int? lastUpdateAt;
  final bool? schemeUser;
  final bool? schemeAdmin;
  final String? explicitRoles;

  MChannelMember({
    required this.channelId,
    required this.userId,
    required this.roles,
    this.lastViewedAt,
    this.msgCount,
    this.mentionCount,
    this.notifyProps,
    this.lastUpdateAt,
    this.schemeUser,
    this.schemeAdmin,
    this.explicitRoles,
  });

  factory MChannelMember.fromJson(Map<String, dynamic> json) {
    return MChannelMember(
      channelId: json['channel_id'] ?? '',
      userId: json['user_id'] ?? '',
      roles: json['roles'] ?? '',
      lastViewedAt: json['last_viewed_at'],
      msgCount: json['msg_count'],
      mentionCount: json['mention_count'],
      notifyProps: json['notify_props'] != null ? MChannelNotifyProps.fromJson(json['notify_props']) : null,
      lastUpdateAt: json['last_update_at'],
      schemeUser: json['scheme_user'],
      schemeAdmin: json['scheme_admin'],
      explicitRoles: json['explicit_roles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'user_id': userId,
      'roles': roles,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (msgCount != null) 'msg_count': msgCount,
      if (mentionCount != null) 'mention_count': mentionCount,
      if (notifyProps != null) 'notify_props': notifyProps?.toJson(),
      if (lastUpdateAt != null) 'last_update_at': lastUpdateAt,
      if (schemeUser != null) 'scheme_user': schemeUser,
      if (schemeAdmin != null) 'scheme_admin': schemeAdmin,
      if (explicitRoles != null) 'explicit_roles': explicitRoles,
    };
  }
}

/// Channel stats model
class MChannelStats {
  final String channelId;
  final int memberCount;
  final int guestCount;
  final int pinnedPostCount;

  MChannelStats({
    required this.channelId,
    required this.memberCount,
    required this.guestCount,
    required this.pinnedPostCount,
  });

  factory MChannelStats.fromJson(Map<String, dynamic> json) {
    return MChannelStats(
      channelId: json['channel_id'] ?? '',
      memberCount: json['member_count'] ?? 0,
      guestCount: json['guest_count'] ?? 0,
      pinnedPostCount: json['pinnedpost_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'member_count': memberCount,
      'guest_count': guestCount,
      'pinnedpost_count': pinnedPostCount,
    };
  }
}
