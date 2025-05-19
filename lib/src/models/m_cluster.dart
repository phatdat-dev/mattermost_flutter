/// Cluster info model
class MCluster {
  final String id;
  final String version;
  final String configHash;
  final String internodeUrl;
  final String hostname;
  final int lastPing;
  final bool isAlive;

  MCluster({
    required this.id,
    required this.version,
    required this.configHash,
    required this.internodeUrl,
    required this.hostname,
    required this.lastPing,
    required this.isAlive,
  });

  factory MCluster.fromJson(Map<String, dynamic> json) {
    return MCluster(
      id: json['id'] ?? '',
      version: json['version'] ?? '',
      configHash: json['config_hash'] ?? '',
      internodeUrl: json['internode_url'] ?? '',
      hostname: json['hostname'] ?? '',
      lastPing: json['last_ping'] ?? 0,
      isAlive: json['is_alive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'config_hash': configHash,
      'internode_url': internodeUrl,
      'hostname': hostname,
      'last_ping': lastPing,
      'is_alive': isAlive,
    };
  }
}
