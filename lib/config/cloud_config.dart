abstract final class CloudConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lfoczkivkesxxmuowebm.supabase.co',
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_NGm5Y-8u5SwycozyfhyYjw_keRVTpka',
  );

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') && supabasePublishableKey.isNotEmpty;
}
