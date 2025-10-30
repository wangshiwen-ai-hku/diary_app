import 'package:hive/hive.dart';
import '../models/diary.dart';
import '../../utils/mock_data.dart';
import 'diary_repository.dart';

class LocalDiaryRepository implements DiaryRepository {
  static const String _boxName = 'diaries';
  Box<Diary>? _box;

  Future<Box<Diary>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Diary>(_boxName);
    return _box!;
  }

  @override
  Future<List<Diary>> getDiaries({int? limit, DateTime? startDate}) async {
    final box = await _getBox();
    var diaries = box.values.toList();

    // 按日期筛选
    if (startDate != null) {
      diaries = diaries.where((d) => d.date.isAfter(startDate)).toList();
    }

    // 按日期降序排序（最新的在前）
    diaries.sort((a, b) => b.date.compareTo(a.date));

    // 限制数量
    if (limit != null && limit > 0) {
      diaries = diaries.take(limit).toList();
    }

    return diaries;
  }

  @override
  Future<Diary?> getDiary(String id) async {
    final box = await _getBox();
    return box.values.firstWhere(
      (diary) => diary.id == id,
      orElse: () => throw Exception('Diary not found'),
    );
  }

  @override
  Future<Diary> createDiary(Diary diary) async {
    final box = await _getBox();
    await box.put(diary.id, diary);
    return diary;
  }

  @override
  Future<Diary> updateDiary(Diary diary) async {
    final box = await _getBox();
    await box.put(diary.id, diary);
    return diary;
  }

  @override
  Future<void> deleteDiary(String id) async {
    final box = await _getBox();
    final diary = box.values.firstWhere(
      (d) => d.id == id,
      orElse: () => throw Exception('Diary not found'),
    );
    await diary.delete();
  }

  @override
  Future<String> generateAIDiary({
    required String content,
    required String type,
    required String style,
    String? mood,
  }) async {
    // Mock AI生成（开发阶段）
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 返回Mock生成的日记
    return MockDataGenerator.generateMockAIDiary(content, style);
  }

  // 初始化Mock数据（仅用于开发测试）
  Future<void> initMockData({int count = 10}) async {
    final box = await _getBox();
    if (box.isEmpty) {
      final mockDiaries = MockDataGenerator.generateDiaries(count);
      for (var diary in mockDiaries) {
        await box.put(diary.id, diary);
      }
    }
  }

  // 清空所有数据
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
