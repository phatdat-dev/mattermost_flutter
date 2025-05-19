import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for job-related endpoints
class MJobsApi {
  final Dio _dio;

  MJobsApi(this._dio);

  /// Get jobs
  Future<List<MJob>> getJobs({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get('/api/v4/jobs', queryParameters: {'page': page.toString(), 'per_page': perPage.toString()});
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
  Future<MJob> createJob(MCreateJobRequest request) async {
    try {
      final response = await _dio.post('/api/v4/jobs', data: request.toJson());
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
  Future<List<MJob>> getJobsByType(String jobType, {int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get('/api/v4/jobs/type/$jobType', queryParameters: {'page': page.toString(), 'per_page': perPage.toString()});
      return (response.data as List).map((jobData) => MJob.fromJson(jobData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
