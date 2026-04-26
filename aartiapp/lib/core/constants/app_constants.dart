/// App-level constants used across features and services.
class AppConstants {
  AppConstants._();

  /// Maximum number of activity log entries retained in local storage.
  static const int activityLogMaxEntries = 500;

  /// JSONL file name used by [ActivityLogService].
  static const String activityLogFileName = 'aarti_activity_log.jsonl';
}