import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:absensi_honor_android/network/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static UserService? _instance;

  factory UserService() => _instance ??= UserService._();

  UserService._();

  Future<Response>login(String username, String password) async {
    var response = await Api().api.post('/security/login', data: {
      'username': username,
      'password': password
    });


    if (response.statusCode == 200) {
      final storage = new FlutterSecureStorage();

      await storage.write(key: 'access_token', value: response.data['token']);
      await storage.write(key: 'refresh_token', value: response.data['refresh_token']);
    }

    return response;
  }

  Future<Response> refreshToken() async {

    final storage = new FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refresh_token');

    var response = await Api().api.post('/security/refresh-token', data: {
      'refresh_token': refreshToken
    });

    if (response.statusCode == 200) {

      await storage.write(key: 'access_token', value: response.data['token']);
      await storage.write(key: 'refresh_token', value: response.data['refresh_token']);
    } else {
      storage.deleteAll();
    }

    return response;

  }

  Future<void> logout() async {

    final storage = new FlutterSecureStorage();
    final pref = await SharedPreferences.getInstance();
   
      storage.deleteAll();
      pref.clear();


  }

  Future<Response> register(String name, String username, String password) async {
    var response = await Api().api.post('/api/users', data: {
      'username': username,
      'password': password,
      'name': name
    });

    return response;
  }

  Future<Response> getMe() async {
    var response = await Api().api.get('/api/account/me');

    return response;
  }

  Future<Response> getUser(String id) async {
    var response = await Api().api.get('/api/users/'+id);
    return response;
  }

  Future<Response> updateUser(String id, Map<String, dynamic> data) async {
    var response = await Api().api.put(
      '/api/users/$id',
      data: {
        'name': data['name'] ?? '',
        'phoneNumber': data['phoneNumber'] ?? '',
        'address': data['address'] ?? '',
        'description': data['description'] ?? ''
      }
    );

    return response;
  }



}