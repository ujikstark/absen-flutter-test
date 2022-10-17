import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRepository {



  Future<String> getAccessToken (FlutterSecureStorage storage) async {
    
    var accessToken;
    
    accessToken = await storage.read(key: 'access_token');
    
    return accessToken;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  int getAccessTokenRemainingTime(String jwt) {
    if (jwt != null) {
      final parts = jwt.split('.');
      if (parts.length != 3) {
        return 0;
      }

      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);

      if (payloadMap is! Map<String, dynamic>) {
        return 0;
      }

      if (payloadMap.containsKey('exp')) {
        return payloadMap['exp'];
      }

    }

    return 0;
  }

  

}