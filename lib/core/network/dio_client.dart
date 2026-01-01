import 'package:dio/dio.dart';
import 'package:horus_cafee/core/constants/api_constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient._internal(this._dio) {
    _initializeInterceptors();
  }

  /// ✅ ASYNC FACTORY (THIS SOLVES YOUR PROBLEM)
  static Future<DioClient> create() async {
    final baseUrl = await ApiConstants.getBaseUrl();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        responseType: ResponseType.json,
      ),
    );

    return DioClient._internal(dio);
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("NETWORK: [${options.method}] ${options.uri}");
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            "NETWORK: [${response.statusCode}] ${response.requestOptions.uri}",
          );
          handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint("NETWORK ERROR: ${e.response?.statusCode} | ${e.message}");
          handler.next(e);
        },
      ),
    );
  }

  // =====================
  // HTTP METHODS
  // =====================

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(url, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

// Global debugPrint helper for local network logging
void debugPrint(String message) {
  assert(() {
    print(message);
    return true;
  }());
}
