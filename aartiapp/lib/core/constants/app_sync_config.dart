/// User sync configuration resolved from compile-time environment values.
class AppSyncConfig {
  AppSyncConfig._();

  /// n8n webhook URL for best-effort user profile and settings sync.
  static const String userSyncWebhookUrl = String.fromEnvironment(
    'AARTI_USER_SYNC_WEBHOOK_URL',
    defaultValue: 'https://n8n.foozylab.com/webhook/aartiapp-user-sync',
  );

  /// n8n webhook URL for user-initiated feedback submissions.
  static const String feedbackWebhookUrl = String.fromEnvironment(
    'AARTI_FEEDBACK_WEBHOOK_URL',
    defaultValue: 'https://n8n.foozylab.com/webhook/aartiapp-feedback',
  );

  /// n8n webhook URL for festival calendar content refresh.
  static const String festivalContentWebhookUrl = String.fromEnvironment(
    'AARTI_FESTIVAL_CONTENT_WEBHOOK_URL',
    defaultValue: 'https://n8n.foozylab.com/webhook/aartiapp-festival-content',
  );

  /// n8n webhook URL for aarti catalog content refresh.
  static const String aartiContentWebhookUrl = String.fromEnvironment(
    'AARTI_AARTI_CONTENT_WEBHOOK_URL',
    defaultValue: 'https://n8n.foozylab.com/webhook/aartiapp-aarti-content',
  );

  /// Debounce window for user-triggered settings changes.
  static const Duration userSyncDebounceDelay = Duration(seconds: 5);

  /// Maximum time allowed for the sync request.
  static const Duration userSyncRequestTimeout = Duration(seconds: 15);

  /// Maximum time allowed for the feedback submission request.
  static const Duration feedbackRequestTimeout = Duration(seconds: 15);

  /// Maximum time allowed for content refresh requests.
  static const Duration contentSyncRequestTimeout = Duration(seconds: 15);

  /// Minimum interval before the app refreshes content again.
  static const Duration contentRefreshInterval = Duration(hours: 24);
}
