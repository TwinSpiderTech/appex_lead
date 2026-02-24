class Urls {
  static const String env = 'prod';

  static const String base = env == 'dev'
      // ? '192.168.100.161'
      ? '192.168.100.5:8080'
      // ? 'appex.lvh.me:3000'
      : "appex.twincloud.app";

  static const String baseUrl = '$base/api/v1';
  // static const String subDomain =
  //     "https://flour$baseUrl/app_dashboard/verify_subdomain?subdomain=";
  static const String deviceTokenUpdateURL =
      '$baseUrl/associations/dashboard/update_device_token';
  static const String appVersionURL =
      '$baseUrl/app_config/get_app_version?app_name=';
  static const String authenticationURL = '$baseUrl/authenticate?';
  static const String loadDashboardUrl =
      '$baseUrl/app_dashboard/load_dashboard';
  static const String signoutUrl = '$baseUrl/authentication/logout';
  static const String appUpdate =
      "https://twincloud.app/api/v1/app_config/get_app_version?app_name=";
}
