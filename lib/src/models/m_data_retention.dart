/// Data retention policy model
class MDataRetentionPolicy {
  final String? messageRetentionDays;
  final String? fileRetentionDays;
  final String? boardsRetentionDays;

  MDataRetentionPolicy({
    this.messageRetentionDays,
    this.fileRetentionDays,
    this.boardsRetentionDays,
  });

  factory MDataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    return MDataRetentionPolicy(
      messageRetentionDays: json['message_retention_days'],
      fileRetentionDays: json['file_retention_days'],
      boardsRetentionDays: json['boards_retention_days'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (messageRetentionDays != null) 'message_retention_days': messageRetentionDays,
      if (fileRetentionDays != null) 'file_retention_days': fileRetentionDays,
      if (boardsRetentionDays != null) 'boards_retention_days': boardsRetentionDays,
    };
  }
}
