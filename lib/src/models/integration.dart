/// Integrations list model
class IntegrationsList {
  final List<dynamic> incomingWebhooks;
  final List<dynamic> outgoingWebhooks;
  final List<dynamic> commands;
  final List<dynamic> oauthApps;

  IntegrationsList({
    required this.incomingWebhooks,
    required this.outgoingWebhooks,
    required this.commands,
    required this.oauthApps,
  });

  factory IntegrationsList.fromJson(Map<String, dynamic> json) {
    return IntegrationsList(
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
