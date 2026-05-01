/// User sync configuration resolved from compile-time environment values.
class AppSyncConfig {
  AppSyncConfig._();

  /// n8n webhook URL for best-effort user profile and settings sync.
  static const String userSyncWebhookUrl = String.fromEnvironment(
    'AARTI_USER_SYNC_WEBHOOK_URL',
  );

  /// Debounce window for user-triggered settings changes.
  static const Duration userSyncDebounceDelay = Duration(seconds: 5);

  /// Maximum time allowed for the sync request.
  static const Duration userSyncRequestTimeout = Duration(seconds: 15);
}
