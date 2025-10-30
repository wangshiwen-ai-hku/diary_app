import 'package:cloud_functions/cloud_functions.dart';

class FirebaseAIService {
  final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
    region: 'asia-northeast1', // 东京region
  );

  /// 生成日记
  Future<String> generateDiary({
    required String content,
    required String style,
    String? mood,
    String provider = 'gemini',
  }) async {
    try {
      final callable = functions.httpsCallable('generateDiary');
      final result = await callable.call({
        'content': content,
        'style': style,
        'mood': mood,
        'provider': provider,
      });

      if (result.data['success'] == true) {
        return result.data['data']['generated_text'];
      } else {
        throw Exception('生成失败');
      }
    } on FirebaseFunctionsException catch (e) {
      print('Firebase Functions error: ${e.code} - ${e.message}');
      throw Exception('AI生成失败: ${e.message}');
    } catch (e) {
      print('Error: $e');
      throw Exception('生成失败: $e');
    }
  }

  /// 重新生成日记
  Future<String> regenerateDiary({
    required String originalContent,
    required String previousAIContent,
    required String style,
    String? mood,
    String provider = 'gemini',
  }) async {
    try {
      final callable = functions.httpsCallable('regenerateDiary');
      final result = await callable.call({
        'originalContent': originalContent,
        'previousAIContent': previousAIContent,
        'style': style,
        'mood': mood,
        'provider': provider,
      });

      if (result.data['success'] == true) {
        return result.data['data']['generated_text'];
      } else {
        throw Exception('重新生成失败');
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('重新生成失败: ${e.message}');
    } catch (e) {
      throw Exception('重新生成失败: $e');
    }
  }
}
