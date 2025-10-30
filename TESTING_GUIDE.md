# Testing Guide

## 🧪 Test Structure

```
test/
├── data/
│   ├── models/
│   │   └── diary_test.dart
│   └── repositories/
│       └── local_diary_repository_test.dart
├── services/
│   └── ai_service_test.dart
├── ui/
│   ├── pages/
│   │   ├── home_page_test.dart
│   │   └── detail_page_test.dart
│   └── widgets/
│       └── flip_diary_card_test.dart
└── integration/
    └── app_test.dart
```

## 🚀 Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/services/ai_service_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run integration tests
```bash
flutter drive --target=test_driver/app.dart
```

### Run tests in watch mode (continuously)
```bash
# Install fswatch (macOS)
brew install fswatch

# Watch and run tests on file changes
fswatch -o lib/ test/ | xargs -n1 -I{} flutter test
```

## 📝 Test Files

### 1. Model Tests

**File**: `test/data/models/diary_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:love_diary/data/models/diary.dart';

void main() {
  group('Diary Model Tests', () {
    test('Create diary instance', () {
      final diary = Diary(
        id: '1',
        date: DateTime(2024, 1, 1),
        rawContent: 'Test content',
        type: 'sweet',
        style: 'warm',
      );

      expect(diary.id, '1');
      expect(diary.rawContent, 'Test content');
      expect(diary.type, 'sweet');
    });

    test('Diary serialization', () {
      final diary = Diary(
        id: '1',
        date: DateTime(2024, 1, 1),
        rawContent: 'Test',
        type: 'sweet',
        style: 'warm',
      );

      final json = diary.toJson();
      final fromJson = Diary.fromJson(json);

      expect(fromJson.id, diary.id);
      expect(fromJson.rawContent, diary.rawContent);
    });
  });
}
```

### 2. Repository Tests

**File**: `test/data/repositories/local_diary_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_diary/data/models/diary.dart';
import 'package:love_diary/data/repositories/local_diary_repository.dart';

void main() {
  late LocalDiaryRepository repository;
  late Box<Diary> testBox;

  setUp(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DiaryAdapter());
    testBox = await Hive.openBox<Diary>('test_diaries');
    repository = LocalDiaryRepository();
  });

  tearDown(() async {
    await testBox.clear();
    await testBox.close();
  });

  group('LocalDiaryRepository Tests', () {
    test('Create diary', () async {
      final diary = Diary(
        id: '1',
        date: DateTime.now(),
        rawContent: 'Test',
        type: 'sweet',
        style: 'warm',
      );

      final created = await repository.createDiary(diary);
      expect(created.id, diary.id);
    });

    test('Get diaries', () async {
      // Create test diaries
      await repository.initMockData(count: 5);
      
      final diaries = await repository.getDiaries();
      expect(diaries.length, 5);
    });

    test('Update diary', () async {
      final diary = Diary(
        id: '1',
        date: DateTime.now(),
        rawContent: 'Original',
        type: 'sweet',
        style: 'warm',
      );

      await repository.createDiary(diary);
      
      final updated = diary.copyWith(rawContent: 'Updated');
      await repository.updateDiary(updated);
      
      final fetched = await repository.getDiary('1');
      expect(fetched?.rawContent, 'Updated');
    });

    test('Delete diary', () async {
      final diary = Diary(
        id: '1',
        date: DateTime.now(),
        rawContent: 'Test',
        type: 'sweet',
        style: 'warm',
      );

      await repository.createDiary(diary);
      await repository.deleteDiary('1');
      
      expect(
        () => repository.getDiary('1'),
        throwsException,
      );
    });
  });
}
```

### 3. AI Service Tests

**File**: `test/services/ai_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

// This file will test the AI service once implemented

@GenerateMocks([http.Client])
void main() {
  group('AI Service Tests', () {
    test('Generate diary with Gemini API', () async {
      // TODO: Implement when AI service is ready
      expect(true, true);
    });

    test('Handle API errors gracefully', () async {
      // TODO: Implement error handling tests
      expect(true, true);
    });

    test('Respect rate limits', () async {
      // TODO: Implement rate limiting tests
      expect(true, true);
    });
  });
}
```

### 4. Widget Tests

**File**: `test/ui/widgets/flip_diary_card_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:love_diary/data/models/diary.dart';
import 'package:love_diary/ui/widgets/flip_diary_card.dart';

void main() {
  group('FlipDiaryCard Widget Tests', () {
    testWidgets('Renders diary card', (WidgetTester tester) async {
      final diary = Diary(
        id: '1',
        date: DateTime(2024, 1, 1),
        rawContent: 'Test content',
        aiContent: '# AI Generated',
        type: 'sweet',
        style: 'warm',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipDiaryCard(diary: diary),
          ),
        ),
      );

      expect(find.text('Sweet Moment'), findsOneWidget);
    });

    testWidgets('Flips card on tap', (WidgetTester tester) async {
      final diary = Diary(
        id: '1',
        date: DateTime(2024, 1, 1),
        rawContent: 'Test',
        aiContent: 'AI Content',
        type: 'sweet',
        style: 'warm',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipDiaryCard(diary: diary),
          ),
        ),
      );

      // Tap to flip
      await tester.tap(find.byType(FlipDiaryCard));
      await tester.pumpAndSettle();

      // Should show AI content side
      expect(find.text('AI Diary'), findsOneWidget);
    });
  });
}
```

### 5. Integration Tests

**File**: `test/integration/app_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:love_diary/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete diary creation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap create button
      await tester.tap(find.text('New Entry'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'Test diary content',
      );

      // Submit
      await tester.tap(find.text('Generate Diary'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify diary appears in list
      expect(find.byType(FlipDiaryCard), findsWidgets);
    });

    testWidgets('Theme switching works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open theme menu
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();

      // Select light theme
      await tester.tap(find.text('Light Minimal'));
      await tester.pumpAndSettle();

      // Verify theme changed
      // Add specific theme verification
    });
  });
}
```

## 🎯 Test Coverage Goals

- **Overall**: > 80%
- **Models**: 100%
- **Repositories**: > 90%
- **Services**: > 85%
- **UI Widgets**: > 70%
- **Pages**: > 60%

## 📊 Current Test Status

### ✅ Ready to Test
- Data models (Diary)
- Local repository
- Theme provider
- Flip card widget

### 🚧 Pending Implementation
- AI service
- Firebase repository
- Authentication
- Create/Edit pages

### ❌ Not Tested Yet
- Settings page (not created)
- Search functionality (not implemented)
- Export feature (not implemented)

## 🔍 Manual Testing Checklist

### Home Page
- [ ] Diaries display in grid
- [ ] Theme switcher works
- [ ] Responsive layout (mobile, tablet, desktop)
- [ ] Hover effects on cards
- [ ] Empty state shows correctly

### Diary Card
- [ ] Front shows date, type, mood
- [ ] Flip animation smooth
- [ ] Back shows AI content
- [ ] Markdown renders correctly
- [ ] Fullscreen button works

### Detail Page
- [ ] Shows all diary information
- [ ] Markdown preview works
- [ ] Source/preview toggle works
- [ ] Share button works
- [ ] Copy functions work

### Create Page
- [ ] Form validation works
- [ ] Type selector works
- [ ] Mood selector works
- [ ] Style selector works
- [ ] AI generation works
- [ ] Save creates diary

### Themes
- [ ] Dark Space theme
- [ ] Light Minimal theme
- [ ] Elegant Dark theme
- [ ] Nordic Light theme
- [ ] Cyberpunk theme
- [ ] Theme persists on restart

## 🐛 Testing Best Practices

### 1. Test Naming
```dart
test('should return diary when id exists', () {});
test('should throw exception when id not found', () {});
```

### 2. Arrange-Act-Assert Pattern
```dart
test('example test', () {
  // Arrange: Set up test data
  final diary = Diary(...);
  
  // Act: Execute the test
  final result = repository.getDiary(diary.id);
  
  // Assert: Verify results
  expect(result, equals(diary));
});
```

### 3. Mock External Dependencies
```dart
@GenerateMocks([DiaryRepository, AuthService])
void main() {
  late MockDiaryRepository mockRepo;
  
  setUp(() {
    mockRepo = MockDiaryRepository();
  });
  
  test('test with mock', () {
    when(mockRepo.getDiaries()).thenAnswer((_) async => []);
    // Test logic
  });
}
```

### 4. Test Edge Cases
- Empty lists
- Null values
- Invalid input
- Network errors
- Large datasets

## 📚 Testing Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Integration Test](https://docs.flutter.dev/testing/integration-tests)
- [Flutter Test Coverage](https://medium.com/flutter-community/test-coverage-for-flutter-apps-aaa7ab0e9c7f)

## 🔧 Testing Tools

### Required Packages
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  integration_test:
    sdk: flutter
```

### Generate Mocks
```bash
flutter pub run build_runner build
```

### CI/CD Testing
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter analyze
```

## 📝 Next Steps

1. **Write unit tests** for existing models and repositories
2. **Create widget tests** for flip card and other widgets
3. **Implement AI service tests** once backend is ready
4. **Add integration tests** for complete user flows
5. **Set up CI/CD** for automated testing
6. **Monitor coverage** and aim for >80%
