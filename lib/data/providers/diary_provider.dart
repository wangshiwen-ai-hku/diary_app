import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary.dart';
import '../repositories/local_diary_repository.dart';

// Local diary repository provider
final diaryRepositoryProvider = Provider<LocalDiaryRepository>((ref) {
  return LocalDiaryRepository();
});

// Diaries list provider
final diariesProvider = StateNotifierProvider<DiariesNotifier, List<Diary>>((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return DiariesNotifier(repository);
});

class DiariesNotifier extends StateNotifier<List<Diary>> {
  final LocalDiaryRepository _repository;

  DiariesNotifier(this._repository) : super([]) {
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    state = await _repository.getDiaries();
  }

  Future<void> addDiary(Diary diary) async {
    await _repository.createDiary(diary);
    await _loadDiaries();
  }

  Future<void> updateDiary(Diary diary) async {
    await _repository.updateDiary(diary);
    await _loadDiaries();
  }

  Future<void> deleteDiary(String id) async {
    await _repository.deleteDiary(id);
    await _loadDiaries();
  }

  Future<void> refresh() async {
    await _loadDiaries();
  }
  
  // Initialize with mock data for testing
  Future<void> initMockData({int count = 10}) async {
    await _repository.initMockData(count: count);
    await _loadDiaries();
  }
}
