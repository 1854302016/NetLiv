import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static String get _baseUrl {
    return 'https://hemtest.webultrademo.com/api';
  }

  static Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> _decode(http.Response response) async {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    if (response.statusCode >= 400) {
      throw ApiException(body is Map ? (body['message'] ?? 'Something went wrong.') : 'Something went wrong.');
    }
    return _fixHostForEmulator(body) as Map<String, dynamic>;
  }

  /// The backend generates absolute URLs (posters, videos, ...) using its own
  /// host, which is only reachable as `127.0.0.1` from a browser on the same
  /// machine. The Android emulator can't resolve that address as itself, so
  /// rewrite it to `10.0.2.2` (the emulator's alias for the host machine)
  /// wherever it appears in a decoded response.
  static dynamic _fixHostForEmulator(dynamic value) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (value is String) {
        return value.replaceFirst('127.0.0.1:8123', '10.0.2.2:8123');
      }
      if (value is Map) {
        return value.map((key, v) => MapEntry(key as String, _fixHostForEmulator(v)));
      }
      if (value is List) {
        return value.map(_fixHostForEmulator).toList();
      }
    }
    return value;
  }

  /// Requests an OTP for [phone]. Returns the OTP for local testing when the
  /// backend is running outside production (no real SMS gateway wired up yet).
  static Future<String?> requestOtp(String phone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/otp/request'),
      headers: _headers(),
      body: jsonEncode({'phone': phone}),
    );
    final data = await _decode(response);
    return data['debug_otp'] as String?;
  }

  /// Verifies [otp] for [phone]. Returns the bearer token and whether this
  /// account has never finished onboarding (language + plan) before.
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/otp/verify'),
      headers: _headers(),
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    final data = await _decode(response);
    return {
      'token': data['token'] as String,
      'isNewUser': data['isNewUser'] as bool? ?? true,
    };
  }

  /// Marks onboarding (language + plan selection) as finished for the
  /// signed-in user, so it isn't shown again on future logins.
  static Future<void> completeOnboarding(String token) async {
    await http.post(Uri.parse('$_baseUrl/auth/complete-onboarding'), headers: _headers(token));
  }

  static Future<void> logout(String token) async {
    await http.post(Uri.parse('$_baseUrl/auth/logout'), headers: _headers(token));
  }

  /// Number of active sessions (Sanctum tokens) for the signed-in user.
  static Future<int> fetchDeviceCount(String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/auth/devices'), headers: _headers(token));
    final data = await _decode(response);
    return data['count'] as int? ?? 1;
  }

  static Future<List<dynamic>> _decodeList(http.Response response) async {
    final body = await _decode(response);
    return body['data'] as List<dynamic>? ?? [];
  }

  /// Raw home feed payload: {banners, topTen, trending, originals, rowsByGenre}.
  static Future<Map<String, dynamic>> fetchHome() async {
    final response = await http.get(Uri.parse('$_baseUrl/home'), headers: _headers());
    return _decode(response);
  }

  static Future<List<dynamic>> fetchGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/genres'), headers: _headers());
    return _decodeList(response);
  }

  static Future<List<dynamic>> fetchUpcoming() async {
    final response = await http.get(Uri.parse('$_baseUrl/upcoming'), headers: _headers());
    return _decodeList(response);
  }

  static Future<List<dynamic>> fetchSubscriptionPlans() async {
    final response = await http.get(Uri.parse('$_baseUrl/subscription-plans'), headers: _headers());
    return _decodeList(response);
  }

  /// Full media catalog, optionally filtered by [search] title or [type] ('movie'/'series').
  static Future<List<dynamic>> fetchMedia({String? search, String? type}) async {
    final query = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final uri = Uri.parse('$_baseUrl/media').replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.get(uri, headers: _headers());
    return _decodeList(response);
  }

  static Future<List<dynamic>> fetchShorts() async {
    final response = await http.get(Uri.parse('$_baseUrl/shorts'), headers: _headers());
    return _decodeList(response);
  }

  static Future<List<dynamic>> fetchProfiles(String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/profiles'), headers: _headers(token));
    return _decodeList(response);
  }

  static Future<Map<String, dynamic>> createProfile(
    String token, {
    required String name,
    String? avatarUrl,
    bool isKids = false,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/profiles'),
      headers: _headers(token),
      body: jsonEncode({'name': name, 'avatarUrl': avatarUrl, 'isKids': isKids}),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token,
    String profileId, {
    required String name,
    String? avatarUrl,
    bool isKids = false,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/profiles/$profileId'),
      headers: _headers(token),
      body: jsonEncode({'name': name, 'avatarUrl': avatarUrl, 'isKids': isKids}),
    );
    return _decode(response);
  }

  static Future<void> deleteProfile(String token, String profileId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/profiles/$profileId'),
      headers: _headers(token),
    );
    await _decode(response);
  }

  /// Starts a Razorpay checkout for [planId]. Returns the order details
  /// needed to open Razorpay's checkout UI.
  static Future<Map<String, dynamic>> checkout(String token, String planId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/checkout'),
      headers: _headers(token),
      body: jsonEncode({'planId': planId}),
    );
    return _decode(response);
  }

  /// Verifies a completed Razorpay payment and activates the subscription.
  static Future<void> verifyPayment(
    String token, {
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/checkout/verify'),
      headers: _headers(token),
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );
    await _decode(response);
  }

  /// Real billing history + payment method for the signed-in user.
  static Future<Map<String, dynamic>> fetchBilling(String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/billing'), headers: _headers(token));
    final data = await _decode(response);
    return data['data'] as Map<String, dynamic>? ?? {};
  }

  /// Fetches continue watching items for the authenticated user and active profile.
  static Future<List<dynamic>> fetchContinueWatching(String token, {String? profileId}) async {
    final query = <String, String>{
      if (profileId != null && profileId.isNotEmpty) 'profile_id': profileId,
    };
    final uri = Uri.parse('$_baseUrl/watch-progress').replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.get(uri, headers: _headers(token));
    return _decodeList(response);
  }

  /// Updates or creates watch progress for an item.
  static Future<void> updateWatchProgress(
    String token, {
    required String mediaId,
    String? profileId,
    required double progressSeconds,
    required double durationSeconds,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/watch-progress'),
      headers: _headers(token),
      body: jsonEncode({
        'media_id': mediaId,
        if (profileId != null && profileId.isNotEmpty) 'profile_id': profileId,
        'position_seconds': progressSeconds.toInt(),
        'duration_seconds': durationSeconds.toInt(),
        'progress_percentage': durationSeconds > 0 ? (progressSeconds / durationSeconds) : 0,
      }),
    );
    await _decode(response);
  }

  /// Removes an item from continue watching history.
  static Future<void> removeWatchProgress(String token, String mediaId, {String? profileId}) async {
    final query = <String, String>{
      'media_id': mediaId,
      if (profileId != null && profileId.isNotEmpty) 'profile_id': profileId,
    };
    final uri = Uri.parse('$_baseUrl/watch-progress').replace(queryParameters: query);
    final response = await http.delete(uri, headers: _headers(token));
    await _decode(response);
  }

  /// Fetches notifications for the user.
  static Future<List<dynamic>> fetchNotifications(String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/notifications'), headers: _headers(token));
    return _decodeList(response);
  }

  /// Marks a specific notification as read.
  static Future<void> markNotificationRead(String token, String notificationId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notifications/$notificationId/read'),
      headers: _headers(token),
    );
    await _decode(response);
  }

  /// Registers the device's FCM push token on the backend.
  static Future<void> registerFcmToken(String token, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/devices/fcm-token'),
      headers: _headers(token),
      body: jsonEncode({'fcm_token': fcmToken}),
    );
    await _decode(response);
  }
}
