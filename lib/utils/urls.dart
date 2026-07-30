class Urls {
  static const String env = 'prod';

  static String currentSubdomain = 'fieldforce';

  static String get base {
    if (env == 'dev') {
      return '1b0e-39-56-72-170.ngrok-free.app';
    }
    return '$currentSubdomain.twincloud.app';
  }

  static String get baseUrl => '$base/api/v1';
  static const String subDomain =
      "https://flour.twincloud.app/api/v1/app_dashboard/verify_subdomain?subdomain=";
  static String get deviceTokenUpdateURL =>
      '$baseUrl/associations/dashboard/update_device_token';
  static String get appVersionURL =>
      '$baseUrl/app_config/get_app_version?app_name=';
  static String get authenticationURL => '$baseUrl/authenticate?';
  static String get signupURL => '$baseUrl/authentication/signup';
  static String get deleteAccountURL => '$baseUrl/authentication/disable_user';
  static String get loadDashboardUrl => '$baseUrl/business/dashboard';
  static String get leadsURL => '$baseUrl/business/leads';
  static String get upcomingLeadsURL =>
      '$baseUrl/business/leads?upcoming_followups=within_a_week&page=';
  static String get signoutUrl => '$baseUrl/authentication/logout';
  static String get syncRouteURL => '$baseUrl/business/route_tracking/sync';
}
