/// Import model
class Import {
  final String id;
  final int? createAt;
  final String? status;
  final String? data;

  Import({
    required this.id,
    this.createAt,
    this.status,
    this.data,
  });

  factory Import.fromJson(Map<String, dynamic> json) {
    return Import(
      id: json['id'] ?? '',
      createAt: json['create_at'],
      status: json['status'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (createAt != null) 'create_at': createAt,
      if (status != null) 'status': status,
      if (data != null) 'data': data,
    };
  }
}
