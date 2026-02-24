import 'dart:developer';

import 'package:appex_lead/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/urls.dart';

class ApiServices {
  final _dio = Dio();
  String isTokenRequired = 'requiresToken';
  ApiServices() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          //  options.connectTimeout: const Duration(seconds: 15),
          // receiveTimeout: const Duration(seconds: 20),
          // sendTimeout: const Duration(seconds: 20),
          options.headers['App-Ref'] = 'trading';
          final requiresToken = options.extra[isTokenRequired] != false;

          if (requiresToken) {
            final token = await AuthService.getSessionToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          onError:
          (DioException e, handler) async {
            var statusCode = e.response?.data?['status'] ?? 0;

            if (statusCode >= 500) {
              showErrorMessage(message: 'Server Error');
              log('Server error with status code: $statusCode');
            } else if (statusCode == 401) {
              showErrorMessage(message: "Unauthorized request");
              log('Unauthorized request');
            } else if (statusCode >= 400) {
              // Client errors
              final message =
                  e.response?.data['message'] ??
                  'Request failed. Please check your input.';
              showErrorMessage(message: message);
            } else {
              showErrorMessage(message: 'Network error. Please try again.');
            }
          };

          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getAppVersions(String platform) async {
    String url =
        "${Urls.env == 'dev' ? "http://" : "https://"}${Urls.appVersionURL}$platform";
    try {
      final response = await _dio.get(url);
      if (response.data?['status'] == 200) {
        return response.data;
      } else {
        var err = response.data?['messages']?[0];
        showToast(message: err.toString());
        log('Error: $err');
        return null;
      }
    } catch (e) {
      showToast(message: 'Failed to fetch app version!');
      log('Error on fetching app version: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getData(String token, String url) async {
    // String? subdomain = await AuthService.getSubdomain();
    String _url = "${Urls.env == 'dev' ? "http://" : "https://"}$url";

    try {
      String url = _url;
      log(url);
      final response = await _dio.get(url);
      if (response.data?['status'] == 200) {
        return response.data;
      } else {
        var err = response.data?['messages']?[0];
        showToast(message: err.toString());
        log('Error: $err');
        return null;
      }
    } catch (e) {
      showToast(message: 'Failed to fetch data!');
      log('Error on fetching data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> authenticate(
    String email,
    String password,
  ) async {
    log(email);
    // String? subdomain = await AuthService.getSubdomain();

    try {
      String url =
          "${Urls.env == 'dev' ? "http://" : "https://"}${Urls.authenticationURL}";
      // String url = "https://${Urls.authenticationURL}";
      log(url);
      var data = {'email': email, 'password': password};
      final response = await _dio.post(
        url,
        data: data,
        options: Options(extra: {isTokenRequired: false}),
      );
      if (response.data?['status'] == 200) {
        return response.data;
      } else {
        var err = response.data?['messages']?[0];
        showToast(message: err.toString());
        log('Error: $err');
        return null;
      }
    } catch (e) {
      showToast(message: 'Failed to login!');
      log('Error on logging in: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loadDashboard() async {
    // log(appVerionUrl);
    try {
      String url =
          "${Urls.env == 'dev' ? "http://" : "https://"}${Urls.loadDashboardUrl}";
      final response = await _dio.get(url);
      if (response.data?['status'] == 200) {
        return response.data;
      } else if (response.data?['status'] == 401) {
        showToast(message: "Session timeout. Login again!");
        AuthService.logout();
        return null;
      } else {
        var err = response.data?['messages']?[0];
        showToast(message: err.toString());
        log('Error: $err');
        return null;
      }
    } catch (e) {
      showToast(message: 'Failed to load dashboard data!');
      log('Error on loading dashboard data: $e');
    }
  }

  Future<void> logout() async {
    try {
      String url =
          "${Urls.env == 'dev' ? "http://" : "https://"}${Urls.signoutUrl}";
      print(url);

      await _dio.delete(url, options: Options(extra: {isTokenRequired: true}));
    } catch (e) {
      showToast(message: 'Failed to logout!');
      log('Error on logging out: $e');
    }
  }

  Future<Map<String, dynamic>?> updateDeviceToken(String deviceToken) async {
    // log(appVerionUrl);
    try {
      String url = Urls.deviceTokenUpdateURL;
      print(url);
      var data = {'device_token': deviceToken};
      final response = await _dio.put(url, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logoutUser(toastMessage: "Session Expired!");

        return null;
      }
      log('Dio error: ${e.message}');
      return null;
    } catch (e) {
      log('Error occurred: $e');
      return null;
    }
  }
}
