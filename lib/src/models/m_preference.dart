/// Preference model
class MPreference {
  final String userId;
  final String category;
  final String name;
  final String value;

  MPreference({required this.userId, required this.category, required this.name, required this.value});

  factory MPreference.fromJson(Map<String, dynamic> json) {
    return MPreference(userId: json['user_id'] ?? '', category: json['category'] ?? '', name: json['name'] ?? '', value: json['value'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'category': category, 'name': name, 'value': value};
  }
}
