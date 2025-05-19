class TimeZone {
  String? automaticTimezone;
  String? manualTimezone;
  bool? useAutomaticTimezone;

  TimeZone({this.automaticTimezone, this.manualTimezone, this.useAutomaticTimezone});

  factory TimeZone.fromJson(Map<String, dynamic> json) {
    return TimeZone(
      automaticTimezone: json['automaticTimezone'] as String?,
      manualTimezone: json['manualTimezone'] as String?,
      useAutomaticTimezone: json['useAutomaticTimezone'] != null ? bool.tryParse(json['useAutomaticTimezone']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'automaticTimezone': automaticTimezone, 'manualTimezone': manualTimezone, 'useAutomaticTimezone': useAutomaticTimezone};
  }
}
