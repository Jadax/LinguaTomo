abstract final class CloudConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') && supabasePublishableKey.isNotEmpty;
}
