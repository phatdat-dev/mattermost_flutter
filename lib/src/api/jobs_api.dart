import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for job-related endpoints
class JobsApi {
  final Dio _dio;

  JobsApi(this._dio);

  /// Get jobs
  Future<List<Job>> getJobs({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/jobs',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((jobData) => Job.fromJson(jobData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a job
  Future<Job> getJob(String jobId) async {
    try {
      final response = await _dio.get('/api/v4/jobs/$jobId');
      return Job.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a job
  Future<Job> createJob(CreateJobRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/jobs',
        data: request.toJson(),
      );
      return Job.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a job
  Future<Job> cancelJob(String jobId) async {
    try {
      final response = await _dio.post('/api/v4/jobs/$jobId/cancel');
      return Job.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get jobs by type
  Future<List<Job>> getJobsByType(
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
      return (response.data as List)
          .map((jobData) => Job.fromJson(jobData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
