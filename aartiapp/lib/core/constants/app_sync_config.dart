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

  /// Debounce window for user-triggered settings changes.
  static const Duration userSyncDebounceDelay = Duration(seconds: 5);

  /// Maximum time allowed for the sync request.
  static const Duration userSyncRequestTimeout = Duration(seconds: 15);

  /// Maximum time allowed for the feedback submission request.
  static const Duration feedbackRequestTimeout = Duration(seconds: 15);
}
