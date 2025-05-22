/// Export model
class MExport {
  final String id;
  final int? createAt;
  final int? deleteAt;
  final String? actingUserId;
  final String? fileName;
  final String? status;

  MExport({
    required this.id,
    this.createAt,
    this.deleteAt,
    this.actingUserId,
    this.fileName,
    this.status,
  });

  factory MExport.fromJson(Map<String, dynamic> json) {
    return MExport(
      id: json['id'] ?? '',
      createAt: json['create_at'],
      deleteAt: json['delete_at'],
      actingUserId: json['acting_user_id'],
      fileName: json['file_name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (createAt != null) 'create_at': createAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (actingUserId != null) 'acting_user_id': actingUserId,
      if (fileName != null) 'file_name': fileName,
      if (status != null) 'status': status,
    };
  }
}
