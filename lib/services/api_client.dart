import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class BackendException implements Exception {
  final String message;
  const BackendException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  int _activeBaseIndex = 0;

  List<String> getBaseCandidates() {
    final urls = <String>[];
    final configured = backendBaseUrl.trim();
    if (configured.isNotEmpty) urls.add(configured);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (!urls.contains('http://127.0.0.1:8000')) urls.add('http://127.0.0.1:8000');
      if (!urls.contains('http://10.0.2.2:8000')) urls.add('http://10.0.2.2:8000');
    }

    if (urls.isEmpty) urls.add('http://127.0.0.1:8000');
    return urls;
  }

  String getActiveBase() {
    final candidates = getBaseCandidates();
    return candidates[_activeBaseIndex % candidates.length];
  }

  Uri buildUri(String path, [String? baseUrl]) =>
      Uri.parse('${baseUrl ?? getActiveBase()}$path');

  String _extractErrorMessage(Map<String, dynamic> payload, int statusCode) {
    final detail = payload['detail'];
    if (detail is String && detail.trim().isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic>) {
        final msg = first['msg'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
      }
    }
    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) return message;
    return 'Request failed ($statusCode).';
  }

  Future<Map<String, dynamic>> request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final candidates = getBaseCandidates();
    Object? lastNetworkError;
    http.Response? response;

    final ordered = <String>[
      candidates[_activeBaseIndex % candidates.length],
      ...candidates.where((u) => u != candidates[_activeBaseIndex % candidates.length]),
    ];

    for (final baseUrl in ordered) {
      final uri = buildUri(path, baseUrl);
      try {
        if (method == 'GET') {
          response = await _client.get(uri, headers: headers).timeout(networkTimeout);
        } else if (method == 'DELETE') {
          response = await _client.delete(uri, headers: headers).timeout(networkTimeout);
        } else if (method == 'POST') {
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(networkTimeout);
        } else {
          response = await _client
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(networkTimeout);
        }
        _activeBaseIndex = candidates.indexOf(baseUrl);
        break;
      } catch (e) {
        lastNetworkError = e;
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
    }

    if (response == null) {
      throw BackendException('Network error: $lastNetworkError');
    }

    Map<String, dynamic> payload = {};
    if (response.body.isNotEmpty) {
      try {
        payload = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw const BackendException('Invalid server response.');
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendException(_extractErrorMessage(payload, response.statusCode));
    }

    return payload;
  }
}
