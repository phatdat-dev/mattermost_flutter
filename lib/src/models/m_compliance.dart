/// Compliance report model
class MComplianceReport {
  final String id;
  final int? createAt;
  final String userId;
  final String status;
  final int? count;
  final String desc;
  final String type;
  final int? startAt;
  final int? endAt;
  final String? keywords;
  final String? emails;

  MComplianceReport({
    required this.id,
    this.createAt,
    required this.userId,
    required this.status,
    this.count,
    required this.desc,
    required this.type,
    this.startAt,
    this.endAt,
    this.keywords,
    this.emails,
  });

  factory MComplianceReport.fromJson(Map<String, dynamic> json) {
    return MComplianceReport(
      id: json['id'] ?? '',
      createAt: json['create_at'],
      userId: json['user_id'] ?? '',
      status: json['status'] ?? '',
      count: json['count'],
      desc: json['desc'] ?? '',
      type: json['type'] ?? '',
      startAt: json['start_at'],
      endAt: json['end_at'],
      keywords: json['keywords'],
      emails: json['emails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (createAt != null) 'create_at': createAt,
      'user_id': userId,
      'status': status,
      if (count != null) 'count': count,
      'desc': desc,
      'type': type,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (keywords != null) 'keywords': keywords,
      if (emails != null) 'emails': emails,
    };
  }
}
