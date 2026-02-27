/// Networking API — HTTP requests with the >> pipe operator.
///
/// ```dart
/// // Fire-and-forget into state
/// fetch("https://api.example.com/todos") >> todos;
///
/// // With loading indicator + error handler
/// fetch(url)
///   .loading(isLoading)
///   .onError((e) => errorMsg.set('$e'))
///   >> todos;
///
/// // Await directly
/// final user = await fetch("https://api.example.com/me");
///
/// // POST / PUT / DELETE
/// post(url, body: {'title': 'Buy milk'}) >> response;
/// await put(url, body: updatedData);
/// await delete(url);
/// ```
library;

export '../core/net/request.dart' show VoxRequest;

import '../core/net/client.dart';
import '../core/net/request.dart';

/// Configure the HTTP client. Optional — only needed if you use a base URL
/// or custom default headers.
///
/// ```dart
/// void main() {
///   configureHttp(baseUrl: 'https://api.example.com');
///   voxApp(home: HomeScreen());
/// }
/// ```
void configureHttp({
  String? baseUrl,
  Map<String, dynamic>? headers,
  Duration? connectTimeout,
  Duration? receiveTimeout,
}) =>
    VoxClient.configure(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

/// HTTP GET. Returns a [VoxRequest] — pipe it into state or await it.
///
/// ```dart
/// fetch(url) >> todos;
/// final data = await fetch(url);
/// ```
VoxRequest<dynamic> fetch(
  String url, {
  Map<String, dynamic>? params,
  Map<String, dynamic>? headers,
}) =>
    VoxRequest(VoxClient.get(url, params: params, headers: headers));

/// HTTP POST.
///
/// ```dart
/// post(url, body: {'title': 'Buy milk'}) >> response;
/// ```
VoxRequest<dynamic> post(
  String url, {
  dynamic body,
  Map<String, dynamic>? params,
  Map<String, dynamic>? headers,
}) =>
    VoxRequest(VoxClient.post(url, body: body, params: params, headers: headers));

/// HTTP PUT.
VoxRequest<dynamic> put(
  String url, {
  dynamic body,
  Map<String, dynamic>? params,
  Map<String, dynamic>? headers,
}) =>
    VoxRequest(VoxClient.put(url, body: body, params: params, headers: headers));

/// HTTP PATCH.
VoxRequest<dynamic> patch(
  String url, {
  dynamic body,
  Map<String, dynamic>? params,
  Map<String, dynamic>? headers,
}) =>
    VoxRequest(
        VoxClient.patch(url, body: body, params: params, headers: headers));

/// HTTP DELETE.
VoxRequest<dynamic> delete(
  String url, {
  Map<String, dynamic>? params,
  Map<String, dynamic>? headers,
}) =>
    VoxRequest(VoxClient.delete(url, params: params, headers: headers));
