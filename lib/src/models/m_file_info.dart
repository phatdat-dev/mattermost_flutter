/// File info model
class MFileInfo {
  final String id;
  final String userId;
  final String postId;
  final String name;
  final String extension;
  final int size;
  final String mimeType;
  final int width;
  final int height;
  final bool hasPreviewImage;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MFileInfo({
    required this.id,
    required this.userId,
    required this.postId,
    required this.name,
    required this.extension,
    required this.size,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.hasPreviewImage,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory MFileInfo.fromJson(Map<String, dynamic> json) {
    return MFileInfo(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      postId: json['post_id'] ?? '',
      name: json['name'] ?? '',
      extension: json['extension'] ?? '',
      size: json['size'] ?? 0,
      mimeType: json['mime_type'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      hasPreviewImage: json['has_preview_image'] ?? false,
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'name': name,
      'extension': extension,
      'size': size,
      'mime_type': mimeType,
      'width': width,
      'height': height,
      'has_preview_image': hasPreviewImage,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// File upload response
class MFileUploadResponse {
  final List<MFileInfo> fileInfos;
  final Map<String, String> clientIds;

  MFileUploadResponse({required this.fileInfos, required this.clientIds});

  factory MFileUploadResponse.fromJson(Map<String, dynamic> json) {
    return MFileUploadResponse(
      fileInfos: (json['file_infos'] as List<dynamic>? ?? []).map((fileInfo) => MFileInfo.fromJson(fileInfo)).toList(),
      clientIds: (json['client_ids'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {'file_infos': fileInfos.map((fileInfo) => fileInfo.toJson()).toList(), 'client_ids': clientIds};
  }
}
