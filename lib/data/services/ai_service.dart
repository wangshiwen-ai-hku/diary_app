import 'package:dio/dio.dart';
import 'dart:convert';

class AIService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // 后端API地址
  // TODO: 部署后替换为实际地址
  final String _baseUrl = 'http://localhost:5000/api';

  /// 生成日记
  Future<String> generateDiary({
    required String content,
    required String style,
    String? mood,
    String provider = 'gemini',
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/generate-diary',
        data: {
          'content': content,
          'style': style,
          'mood': mood,
          'provider': provider,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['generated_text'];
      } else {
        throw Exception(response.data['error'] ?? '生成失败');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('请求超时，请检查网络连接');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('无法连接到服务器，请确保后端服务已启动');
      } else if (e.response != null) {
        final errorMsg = e.response?.data['error'] ?? '未知错误';
        throw Exception(errorMsg);
      } else {
        throw Exception('网络错误: ${e.message}');
      }
    } catch (e) {
      print('AI生成失败: $e');
      rethrow;
    }
  }

  /// 重新生成日记（带历史上下文）
  Future<String> regenerateDiary({
    required String originalContent,
    required String previousAIContent,
    required String style,
    String? mood,
    String provider = 'gemini',
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/regenerate-diary',
        data: {
          'original_content': originalContent,
          'previous_ai_content': previousAIContent,
          'style': style,
          'mood': mood,
          'provider': provider,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['generated_text'];
      } else {
        throw Exception(response.data['error'] ?? '重新生成失败');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('请求超时，请检查网络连接');
      } else if (e.response != null) {
        final errorMsg = e.response?.data['error'] ?? '未知错误';
        throw Exception(errorMsg);
      } else {
        throw Exception('网络错误: ${e.message}');
      }
    } catch (e) {
      print('重新生成失败: $e');
      rethrow;
    }
  }

  /// 检查服务健康状态
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      return response.data;
    } catch (e) {
      print('健康检查失败: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  /// 获取可用的AI提供商列表
  Future<List<Map<String, dynamic>>> getAvailableProviders() async {
    try {
      final response = await _dio.get('$_baseUrl/providers');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(
          response.data['providers'],
        );
      }
      return [];
    } catch (e) {
      print('获取提供商列表失败: $e');
      return [];
    }
  }
}
