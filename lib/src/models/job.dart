/// Job model
class Job {
  final String id;
  final String type;
  final String status;
  final int? startAt;
  final int? lastActivityAt;
  final int? createAt;
  final Map<String, dynamic>? data;

  Job({
    required this.id,
    required this.type,
    required this.status,
    this.startAt,
    this.lastActivityAt,
    this.createAt,
    this.data,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      startAt: json['start_at'],
      lastActivityAt: json['last_activity_at'],
      createAt: json['create_at'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      if (startAt != null) 'start_at': startAt,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (createAt != null) 'create_at': createAt,
      if (data != null) 'data': data,
    };
  }
}

/// Create job request
class CreateJobRequest {
  final String type;
  final Map<String, dynamic>? data;

  CreateJobRequest({
    required this.type,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (data != null) 'data': data,
    };
  }
}
