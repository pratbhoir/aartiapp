/// Analytics configuration resolved from compile-time environment values.
class AppAnalyticsConfig {
  AppAnalyticsConfig._();

  /// Umami send endpoint, for example `https://analytics.example.com/api/send`.
  static const String umamiEndpoint = String.fromEnvironment(
    'AARTI_ANALYTICS_ENDPOINT',
    defaultValue: 'https://umami.foozylab.com/api/send',
  );

  /// Umami website identifier for Aarti Sangrah.
  static const String websiteId = String.fromEnvironment(
    'AARTI_ANALYTICS_WEBSITE_ID',
    defaultValue: '80994821-fd31-418f-9585-4ad5789d0431',
  );

  /// Hostname attached to Umami payloads.
  static const String hostname = String.fromEnvironment(
    'AARTI_ANALYTICS_HOSTNAME',
    defaultValue: 'aartisangrah',
  );

  /// Maximum time allowed for an analytics request.
  static const Duration analyticsRequestTimeout = Duration(seconds: 15);

  /// Browser-like User-Agent used to avoid Umami bot filtering.
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';
}
