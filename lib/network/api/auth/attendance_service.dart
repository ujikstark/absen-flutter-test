import 'package:dio/dio.dart';
import 'package:absensi_honor_android/network/api/api.dart';

class AttendanceService {
  Future<Response> enterAttendance() async {
    var response = await Api().api.post('/api/attendances/enter', data: {});

    return response;
  }

  Future<Response> exitDone(String id) async {
    var response =
        await Api().api.put('/api/attendances/$id/exit-done', data: {});

    return response;
  }

  Future<Response> getAttendance(String path) async {
    var response = await Api().api.get(path);

    return response;
  }

  Future<Response> getAllAttendance() async {
    var response = await Api().api.get('/api/attendances');

    return response;
  }

  Future<Response> getAttendancesByMonth(String month) async {
    var response = await Api().api.get('/api/attendances/month/'+month);

    return response;
  }
}
