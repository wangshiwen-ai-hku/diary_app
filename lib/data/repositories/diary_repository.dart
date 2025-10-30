import '../models/diary.dart';

abstract class DiaryRepository {
  Future<List<Diary>> getDiaries({int? limit, DateTime? startDate});
  Future<Diary?> getDiary(String id);
  Future<Diary> createDiary(Diary diary);
  Future<Diary> updateDiary(Diary diary);
  Future<void> deleteDiary(String id);
  Future<String> generateAIDiary({
    required String content,
    required String type,
    required String style,
    String? mood,
  });
}
