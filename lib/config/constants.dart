class AppConstants {
  // Supabase — replace with your project values
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // Mapbox — replace with your token
  static const mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: 'your-mapbox-token',
  );

  // XP Awards
  static const int xpRouteClaim = 50;
  static const int xpEvidenceUpload = 100;
  static const int xpReportSubmitted = 500;
  static const int xpMediaPickup = 2000;
  static const int xpDailyLogin = 25;

  // Map defaults
  static const double defaultLat = 39.8283; // Center of US
  static const double defaultLng = -98.5795;
  static const double defaultZoom = 4.0;

  // Legal
  static const String quiTamDisclaimer =
      'LEGAL DISCLAIMER: This is NOT legal advice. Filing a qui tam complaint '
      'under the False Claims Act requires a formal sealed lawsuit filed in '
      'federal court. We strongly recommend consulting a whistleblower attorney. '
      'There is no guarantee of any payout or government action. Rewards '
      '(15-30% of recovered funds) are only paid if the government successfully '
      'recovers funds. You are responsible for your own filing and any legal risks.';
}
