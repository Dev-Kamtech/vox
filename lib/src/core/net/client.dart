import 'package:dio/dio.dart';

/// Internal HTTP client. Wraps Dio with vox defaults.
///
/// Used by [VoxRequest] and the API fetch/post/put/delete/patch functions.
/// Developers never touch this — they use the top-level API functions.
abstract final class VoxClient {
  static Dio? _dio;

  static Dio get _instance {
    _dio ??= Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    return _dio!;
  }

  /// Configure the HTTP client. Call once at startup if needed.
  static void configure({
    String? baseUrl,
    Map<String, dynamic>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    final opts = _instance.options;
    if (baseUrl != null) opts.baseUrl = baseUrl;
    if (headers != null) opts.headers.addAll(headers);
    if (connectTimeout != null) opts.connectTimeout = connectTimeout;
    if (receiveTimeout != null) opts.receiveTimeout = receiveTimeout;
  }

  static Future<dynamic> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    final res = await _instance.get(
      url,
      queryParameters: params,
      options: headers != null ? Options(headers: headers) : null,
    );
    return res.data;
  }

  static Future<dynamic> post(
    String url, {
    dynamic body,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    final res = await _instance.post(
      url,
      data: body,
      queryParameters: params,
      options: headers != null ? Options(headers: headers) : null,
    );
    return res.data;
  }

  static Future<dynamic> put(
    String url, {
    dynamic body,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    final res = await _instance.put(
      url,
      data: body,
      queryParameters: params,
      options: headers != null ? Options(headers: headers) : null,
    );
    return res.data;
  }

  static Future<dynamic> patch(
    String url, {
    dynamic body,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    final res = await _instance.patch(
      url,
      data: body,
      queryParameters: params,
      options: headers != null ? Options(headers: headers) : null,
    );
    return res.data;
  }

  static Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    final res = await _instance.delete(
      url,
      queryParameters: params,
      options: headers != null ? Options(headers: headers) : null,
    );
    return res.data;
  }
}
