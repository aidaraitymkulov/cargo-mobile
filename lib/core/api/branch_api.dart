import 'package:dio/dio.dart';
import 'package:cargo_mobile/core/api/dio_client.dart';
import 'package:cargo_mobile/models/branch.dart';

class BranchApi {
  final Dio _dio;

  BranchApi(DioClient client) : _dio = client.dio;

  Future<List<Branch>> getBranches() async {
    final response = await _dio.get('/branches');
    final list = response.data as List;
    return list.map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
  }
}
