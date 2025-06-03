import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for job-related endpoints
class MJobsApi {
  final Dio _dio;

  MJobsApi(this._dio);

  /// Get jobs
  Future<List<MJob>> getJobs({
    int page = 0,
    int perPage = 5,
    String? jobType,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (jobType != null) queryParams['job_type'] = jobType;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        '/api/v4/jobs',
        queryParameters: queryParams,
      );
      return (response.data as List).map((jobData) => MJob.fromJson(jobData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a job
  Future<MJob> getJob(String jobId) async {
    try {
      final response = await _dio.get('/api/v4/jobs/$jobId');
      return MJob.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a job
  Future<MJob> createJob({
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final requestData = {
        'type': type,
        if (data != null) 'data': data,
      };

      final response = await _dio.post('/api/v4/jobs', data: requestData);
      return MJob.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a job
  Future<MJob> cancelJob(String jobId) async {
    try {
      final response = await _dio.post('/api/v4/jobs/$jobId/cancel');
      return MJob.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get jobs by type
  Future<List<MJob>> getJobsByType(
    String jobType, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/jobs/type/$jobType',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((jobData) => MJob.fromJson(jobData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Download the results of a job
  Future<List<int>> downloadJob(String jobId) async {
    try {
      final response = await _dio.get(
        '/api/v4/jobs/$jobId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update the status of a job
  Future<void> updateJobStatus(
    String jobId, {
    required String status,
    bool? force,
  }) async {
    try {
      final data = {
        'status': status,
        if (force != null) 'force': force,
      };

      await _dio.patch(
        '/api/v4/jobs/$jobId/status',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }
}
