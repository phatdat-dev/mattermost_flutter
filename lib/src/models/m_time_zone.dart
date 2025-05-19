class MTimeZone {
  String? automaticTimezone;
  String? manualTimezone;
  bool? useAutomaticTimezone;

  MTimeZone({this.automaticTimezone, this.manualTimezone, this.useAutomaticTimezone});

  factory MTimeZone.fromJson(Map<String, dynamic> json) {
    return MTimeZone(
      automaticTimezone: json['automaticTimezone'] as String?,
      manualTimezone: json['manualTimezone'] as String?,
      useAutomaticTimezone: json['useAutomaticTimezone'] != null ? bool.tryParse(json['useAutomaticTimezone']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'automaticTimezone': automaticTimezone, 'manualTimezone': manualTimezone, 'useAutomaticTimezone': useAutomaticTimezone};
  }
}
