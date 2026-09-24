import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/utils/debug_log.dart';
import 'pronunciation_config.dart';
import 'pronunciation_issues.dart';

class AzureAccess {
  final String token;

  final String endpoint;

  final DateTime expiresAt;

  const AzureAccess({
    required this.token,
    required this.endpoint,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

abstract interface class PronunciationTokenProvider {
  Future<AzureAccess> access();

  Future<void> clear();
}

class AzureTokenProvider implements PronunciationTokenProvider {
  AzureTokenProvider({
    http.Client? client,
    String? tokenUrl,
    DateTime Function()? clock,
  }) : _client = client ?? http.Client(),
       _tokenUrl = tokenUrl ?? PronunciationConfig.tokenUrl,
       _clock = clock ?? DateTime.now;

  final http.Client _client;
  final String _tokenUrl;
  final DateTime Function() _clock;

  AzureAccess? _cached;
  Future<AzureAccess>? _inflight;

  @override
  Future<AzureAccess> access() {
    final cached = _cached;
    if (cached != null && cached.expiresAt.isAfter(_clock())) {
      return Future.value(cached);
    }
    return _inflight ??= _fetch().then(
      (access) {
        _cached = access;
        _inflight = null;
        debugLog(
          'PronunciationAssessment',
          'token acquired, expires at ${access.expiresAt}',
        );
        return access;
      },
      onError: (Object error) {
        _inflight = null;
        throw error;
      },
    );
  }

  Future<AzureAccess> _fetch() async {
    final url = _tokenUrl.trim();
    if (url.isEmpty) {
      throw const PronunciationUnconfiguredException();
    }

    late http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url))
          .timeout(PronunciationConfig.requestTimeout);
    } on TimeoutException {
      throw const PronunciationTimeoutException('token endpoint timeout');
    } on SocketException {
      throw const PronunciationTokenException('token endpoint unreachable');
    } on http.ClientException {
      throw const PronunciationTokenException('token endpoint unreachable');
    }

    if (response.statusCode != 200) {
      throw PronunciationTokenException(
        'token endpoint HTTP ${response.statusCode}',
      );
    }

    Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const PronunciationTokenException('token response is not JSON');
    }
    if (body is! Map<String, dynamic>) {
      throw const PronunciationTokenException('token response is not JSON');
    }

    final token = body['token'];
    final endpoint = body['endpoint'];
    if (token is! String ||
        token.trim().isEmpty ||
        endpoint is! String ||
        endpoint.trim().isEmpty) {
      throw const PronunciationTokenException(
        'token response is missing token/endpoint',
      );
    }

    final expiresInSeconds =
        (body['expiresInSeconds'] as num?)?.toInt() ??
        PronunciationConfig.minutesBeforeTokenExpiry * 60;
    return AzureAccess(
      token: token,
      endpoint: endpoint.trim(),
      expiresAt: _clock().add(Duration(seconds: expiresInSeconds)),
    );
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _inflight = null;
  }
}
