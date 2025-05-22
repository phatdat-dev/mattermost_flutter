/// Integrations list model
class MIntegrations {
  final List<dynamic> incomingWebhooks;
  final List<dynamic> outgoingWebhooks;
  final List<dynamic> commands;
  final List<dynamic> oauthApps;

  MIntegrations({
    required this.incomingWebhooks,
    required this.outgoingWebhooks,
    required this.commands,
    required this.oauthApps,
  });

  factory MIntegrations.fromJson(Map<String, dynamic> json) {
    return MIntegrations(
      incomingWebhooks: json['incoming_webhooks'] ?? [],
      outgoingWebhooks: json['outgoing_webhooks'] ?? [],
      commands: json['commands'] ?? [],
      oauthApps: json['oauth_apps'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incoming_webhooks': incomingWebhooks,
      'outgoing_webhooks': outgoingWebhooks,
      'commands': commands,
      'oauth_apps': oauthApps,
    };
  }
}
