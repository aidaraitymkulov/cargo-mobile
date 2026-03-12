import 'package:dio/dio.dart';

class BranchApi {
  final Dio _dio;

  BranchApi(this._dio);

  Future<List<dynamic>> getBranches() async {
    final response = await _dio.get('/branches');
    return response.data as List<dynamic>;
  }
}
