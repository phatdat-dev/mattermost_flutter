/// Preference model
class Preference {
  final String userId;
  final String category;
  final String name;
  final String value;

  Preference({
    required this.userId,
    required this.category,
    required this.name,
    required this.value,
  });

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      userId: json['user_id'] ?? '',
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category': category,
      'name': name,
      'value': value,
    };
  }
}
