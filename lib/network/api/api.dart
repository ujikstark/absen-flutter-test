import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:absensi_honor_android/network/api/constant/endpoints.dart';

class Api {
  final Dio api = Dio(BaseOptions(
      baseUrl: Endpoints.baseUrl,
      receiveTimeout: Endpoints.receiveTimeout, // 15 seconds
      connectTimeout: Endpoints.connectionTimeout,
      sendTimeout: Endpoints.sendTimeout,
      contentType: Headers.jsonContentType,
    ));
  String? accessToken;

  final _storage = const FlutterSecureStorage();


  Api() {
    
    api.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      accessToken = await _storage.read(key: 'access_token');
     
      options.headers['Authorization'] = 'Bearer $accessToken';
      return handler.next(options);
    }, onError: (DioError error, handler) async {

      if ((error.response?.statusCode == 401 
      && error.response?.data['message'] == "Expired JWT Token"
          )) {
        if (await _storage.containsKey(key: 'refresh_token')) {
          if (await refreshToken()) {
            return handler.resolve(await _retry(error.requestOptions));
          }
        } 
      } 
      return handler.next(error);
    }));
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return api.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    final response = await api
        .post('/security/refresh-token', data: {'refresh_token': refreshToken});

    if (response.statusCode == 200) {
      accessToken = response.data['token'];
      await _storage.write(key: 'access_token', value: accessToken);
      return true;
    } else {
      // refresh token is wrong
      accessToken = null;
      _storage.deleteAll();
      return false;
    }
  }
}