class MMetaData {
  final List<MEmbed>? embeds;
  final List<MEmoji>? emojis;
  final List<MFile>? files;
  final Map<String, MImage>? images;
  final List<MReaction>? reactions;
  final MPriority? priority;
  final List<MAcknowledgement>? acknowledgements;

  MMetaData({
    this.embeds,
    this.emojis,
    this.files,
    this.images,
    this.reactions,
    this.priority,
    this.acknowledgements,
  });

  factory MMetaData.fromJson(Map<String, dynamic> json) {
    return MMetaData(
      embeds: (json['embeds'] as List?)?.map((e) => MEmbed.fromJson(e as Map<String, dynamic>)).toList(),
      emojis: (json['emojis'] as List?)?.map((e) => MEmoji.fromJson(e as Map<String, dynamic>)).toList(),
      files: (json['files'] as List?)?.map((e) => MFile.fromJson(e as Map<String, dynamic>)).toList(),
      images: (json['images'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, MImage.fromJson(value as Map<String, dynamic>))),
      reactions: (json['reactions'] as List?)?.map((e) => MReaction.fromJson(e as Map<String, dynamic>)).toList(),
      priority: json['priority'] != null ? MPriority.fromJson(json['priority'] as Map<String, dynamic>) : null,
      acknowledgements: (json['acknowledgements'] as List?)?.map((e) => MAcknowledgement.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'embeds': embeds?.map((e) => e.toJson()).toList(),
      'emojis': emojis?.map((e) => e.toJson()).toList(),
      'files': files?.map((e) => e.toJson()).toList(),
      'images': images?.map((key, value) => MapEntry(key, value.toJson())),
      'priority': priority?.toJson(),
      'reactions': reactions?.map((e) => e.toJson()).toList(),
    };
  }
}

class MEmbed {
  final String? type;
  final String? url;
  final Object? data; // Optional field for additional embed data

  MEmbed({this.type, this.url, this.data});

  factory MEmbed.fromJson(Map<String, dynamic> json) {
    return MEmbed(
      type: json['type'] as String?,
      url: json['url'] as String?,
      data: json['data'], // This can be any type, so we keep it as Object
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'data': data, // This can be any type, so we keep it as Object
    };
  }
}

class MEmoji {
  /// The ID of the emoji
  final String? id;

  /// The ID of the user that made the emoji
  final String? creatorId;

  /// The name of the emoji
  final String? name;

  /// The time in milliseconds the emoji was made
  final int? createAt;

  /// The time in milliseconds the emoji was last updated
  final int? updateAt;

  /// The time in milliseconds the emoji was deleted
  final int? deleteAt;

  MEmoji({this.id, this.creatorId, this.name, this.createAt, this.updateAt, this.deleteAt});

  factory MEmoji.fromJson(Map<String, dynamic> json) {
    return MEmoji(
      id: json['id'] as String?,
      creatorId: json['creator_id'] as String?,
      name: json['name'] as String?,
      createAt: json['create_at'] as int?,
      updateAt: json['update_at'] as int?,
      deleteAt: json['delete_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'create_at': createAt,
      'update_at': updateAt,
      'delete_at': deleteAt,
    };
  }
}

class MFile {
  /// The unique identifier for this file
  final String? id;

  /// The ID of the user that uploaded this file
  final String? userId;

  /// If this file is attached to a post, the ID of that post
  final String? postId;

  /// The time in milliseconds a file was created
  final int? createAt;

  /// The time in milliseconds a file was last updated
  final int? updateAt;

  /// The time in milliseconds a file was deleted
  final int? deleteAt;

  /// The name of the file
  final String? name;

  /// The extension at the end of the file name
  final String? extension;

  /// The size of the file in bytes
  final int? size;

  /// The MIME type of the file
  final String? mimeType;

  /// If this file is an image, the image metadata
  final MImage? image;

  MFile({
    this.id,
    this.userId,
    this.postId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.name,
    this.extension,
    this.size,
    this.mimeType,
    this.image,
  });

  factory MFile.fromJson(Map<String, dynamic> json) {
    return MFile(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      postId: json['post_id'] as String?,
      createAt: json['create_at'] as int?,
      updateAt: json['update_at'] as int?,
      deleteAt: json['delete_at'] as int?,
      name: json['name'] as String?,
      extension: json['extension'] as String?,
      size: json['size'] as int?,
      mimeType: json['mime_type'] as String?,
      image: json['image'] != null ? MImage.fromJson(json['image'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'create_at': createAt,
      'update_at': updateAt,
      'delete_at': deleteAt,
      'name': name,
      'extension': extension,
      'size': size,
      'mime_type': mimeType,
      'image': image?.toJson(),
    };
  }
}

class MImage {
  /// If this file is an image, the width of the file
  final int? width;

  /// If this file is an image, the height of the file
  final int? height;

  /// If this file is an image, whether or not it has a preview-sized version
  final bool? hasPreviewImage;

  MImage({this.width, this.height, this.hasPreviewImage});

  factory MImage.fromJson(Map<String, dynamic> json) {
    return MImage(
      height: json['height'] as int?,
      width: json['width'] as int?,
      hasPreviewImage: json['has_preview_image'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'width': width,
      'has_preview_image': hasPreviewImage,
    };
  }
}

class MReaction {
  /// The ID of the user that made this reaction
  final String? userId;

  /// The ID of the post to which this reaction was made
  final String? postId;

  /// The name of the emoji that was used for this reaction
  final String? emojiName;

  /// The time in milliseconds this reaction was made
  final int? createAt;

  MReaction({this.userId, this.postId, this.emojiName, this.createAt});

  factory MReaction.fromJson(Map<String, dynamic> json) {
    return MReaction(
      userId: json['user_id'] as String?,
      postId: json['post_id'] as String?,
      emojiName: json['emoji_name'] as String?,
      createAt: json['create_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'emoji_name': emojiName,
      'create_at': createAt,
    };
  }
}

class MPriority {
  /// The priority label of a post, could be either empty, important, or urgent.
  final String? priority;

  /// Whether the post author has requested for acknowledgements or not.
  final bool? requestedAck;

  MPriority({this.priority, this.requestedAck});

  factory MPriority.fromJson(Map<String, dynamic> json) {
    return MPriority(
      priority: json['priority'] as String?,
      requestedAck: json['requested_ack'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priority': priority,
      'requested_ack': requestedAck,
    };
  }
}

class MAcknowledgement {
  /// The ID of the user that made this acknowledgement
  final String? userId;

  /// The ID of the post to which this acknowledgement was made
  final String? postId;

  /// The time in milliseconds in which this acknowledgement was made
  final int? acknowledgedAt;

  MAcknowledgement({this.userId, this.postId, this.acknowledgedAt});

  factory MAcknowledgement.fromJson(Map<String, dynamic> json) {
    return MAcknowledgement(
      userId: json['user_id'] as String?,
      postId: json['post_id'] as String?,
      acknowledgedAt: json['acknowledged_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'acknowledged_at': acknowledgedAt,
    };
  }
}
