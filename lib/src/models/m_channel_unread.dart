/// Channel unread information model
///
/// Represents the unread message and mention counts for a channel for a specific user.
/// This data is typically returned from the `/api/v4/users/{user_id}/channels/{channel_id}/unread` endpoint.
class MChannelUnread {
  /// The team ID that the channel belongs to
  final String teamId;

  /// The channel ID
  final String channelId;

  /// The total number of unread messages in the channel for this user
  final int msgCount;

  /// The number of unread mentions for this user in the channel
  final int mentionCount;

  /// Creates a new [MChannelUnread] instance
  MChannelUnread({
    required this.channelId,
    required this.teamId,
    required this.msgCount,
    required this.mentionCount,
  });

  /// Creates a [MChannelUnread] instance from a JSON map
  factory MChannelUnread.fromJson(Map<String, dynamic> json) {
    return MChannelUnread(
      channelId: json['channel_id'] ?? '',
      teamId: json['team_id'] ?? '',
      msgCount: json['msg_count'] ?? 0,
      mentionCount: json['mention_count'] ?? 0,
    );
  }

  /// Converts this instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'team_id': teamId,
      'msg_count': msgCount,
      'mention_count': mentionCount,
    };
  }
}
