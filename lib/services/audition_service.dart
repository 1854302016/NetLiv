import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/audition_model.dart';
import 'api_service.dart';

class AuditionService {
  static String get _baseUrl => ApiService.baseUrl;

  static Map<String, String> _headers([String? token]) => {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// Fetch list of open audition calls
  static Future<List<AuditionCall>> fetchAuditions() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/auditions'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode >= 400) {
      throw ApiException('Failed to load auditions.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['auditions'] as List<dynamic>? ?? [];
    return list.map((json) => AuditionCall.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch audition registration fee and user pass status
  static Future<AuditionFeeInfo> fetchFeeInfo(String token) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/auditions/fee-info'), headers: _headers(token))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode >= 400) {
      throw ApiException('Failed to load audition pass details.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuditionFeeInfo.fromJson(data);
  }

  /// Start Razorpay checkout for Audition Pass
  static Future<Map<String, dynamic>> checkout(String token, {int? auditionId}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auditions/checkout'),
      headers: {..._headers(token), 'Content-Type': 'application/json'},
      body: jsonEncode({
        ...?auditionId != null ? {'auditionId': auditionId} : null,
      }),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw ApiException(body['message'] ?? 'Could not initiate audition checkout.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Verify Razorpay payment
  static Future<void> verifyPayment(
    String token, {
    required String orderId,
    required String paymentId,
    String? signature,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auditions/verify-payment'),
      headers: {..._headers(token), 'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        ...?signature != null ? {'razorpay_signature': signature} : null,
      }),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw ApiException(body['message'] ?? 'Payment verification failed.');
    }
  }

  /// Submit Audition Application with Multipart File Uploads
  static Future<void> submitAudition(
    String token,
    Map<String, String> fields, {
    File? monologueVideo,
    File? scriptSample,
    List<File>? headshots,
  }) async {
    final uri = Uri.parse('$_baseUrl/auditions/submit');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(_headers(token));
    request.fields.addAll(fields);

    // Video upload
    if (monologueVideo != null && await monologueVideo.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('monologue_video', monologueVideo.path),
      );
    }

    // Script upload (PDF / Word)
    if (scriptSample != null && await scriptSample.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('script_sample', scriptSample.path),
      );
    }

    // Headshots photo uploads
    if (headshots != null && headshots.isNotEmpty) {
      for (int i = 0; i < headshots.length; i++) {
        final photo = headshots[i];
        if (await photo.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('headshots[]', photo.path),
          );
        }
      }
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw ApiException(body['message'] ?? 'Audition submission failed. Please check form fields.');
    }
  }

  /// Fetch Candidate's submitted auditions and real-time status
  static Future<List<AuditionSubmissionItem>> fetchMySubmissions(String token) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/auditions/my-submissions'), headers: _headers(token))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode >= 400) {
      throw ApiException('Failed to load your audition applications.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['submissions'] as List<dynamic>? ?? [];
    return list.map((json) => AuditionSubmissionItem.fromJson(json as Map<String, dynamic>)).toList();
  }
}
