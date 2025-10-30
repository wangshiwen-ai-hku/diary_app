# Development Guide

## 🎯 Current Progress

### ✅ Completed
1. **Data Layer** (`lib/data/`)
   - Models: `Diary` model with Hive adapter
   - Repositories: `LocalDiaryRepository` with Hive storage
   - Providers: `DiaryProvider`, `ThemeProvider` with Riverpod

2. **UI Layer** (`lib/ui/`)
   - Theme system with 5 elegant themes (dark/light modes)
   - Starry animated background
   - Flip diary cards with hover effects
   - Home page with grid layout
   - Detail page with markdown preview
   - Create diary page (partial)

3. **Features**
   - Theme switching (Dark Space, Light Minimal, Elegant Dark, Nordic Light, Cyberpunk)
   - Card flip animation to view AI-generated content
   - Markdown rendering for diary content
   - Frosted glass card design with shadows
   - Kaomoji mood indicators
   - Responsive grid layout

### 🚧 In Progress
1. **Create/Edit Diary Pages**
   - Form UI design
   - AI generation integration
   - Photo upload

2. **Firebase Integration**
   - Authentication
   - Firestore database
   - Cloud Functions for AI generation

### 📋 Next Steps

#### 1. Complete Create/Edit Diary Pages
**Files to modify:**
- `lib/ui/pages/create/create_diary_page.dart`
- `lib/ui/pages/edit/edit_diary_page.dart`

**Tasks:**
- Design form with mood, location, type selectors
- Add markdown editor for content
- Implement AI generation button
- Add photo upload widget
- Connect to repository

#### 2. Implement AI Backend with Firebase
**Files to create/modify:**
- `functions/src/index.ts` - Firebase Cloud Functions
- `lib/services/ai_service.dart` - AI service client
- `lib/data/repositories/firebase_diary_repository.dart`

**Tasks:**
- Set up Firebase Cloud Functions
- Integrate Gemini API in Cloud Functions
- Create AI service wrapper
- Replace mock data with real Firebase calls

#### 3. Settings Page
**Files to create:**
- `lib/ui/pages/settings/settings_page.dart`

**Tasks:**
- User profile settings
- Theme preferences
- Language selection
- Export/backup options
- About section

#### 4. Authentication
**Files to create:**
- `lib/ui/pages/auth/login_page.dart`
- `lib/ui/pages/auth/register_page.dart`
- `lib/services/auth_service.dart`

**Tasks:**
- Firebase Authentication setup
- Login/Register UI
- Social login (Google, Apple)
- Password reset

#### 5. Advanced Features
- Search and filter diaries
- Calendar view
- Statistics and insights
- Sharing functionality
- Multi-language support

## 🛠️ Development Commands

### Run the app
```bash
# Web
flutter run -d chrome --web-port=8080

# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android
```

### Build
```bash
# Web
flutter build web

# iOS
flutter build ios

# Android
flutter build apk
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/ai_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities
│   ├── config_manager.dart  # App configuration
│   └── constants.dart       # Constants
├── data/                    # Data layer
│   ├── models/              # Data models
│   │   └── diary.dart
│   ├── providers/           # Riverpod providers
│   │   ├── diary_provider.dart
│   │   └── theme_provider.dart
│   └── repositories/        # Data repositories
│       ├── diary_repository.dart
│       └── local_diary_repository.dart
├── services/                # Services (to be implemented)
│   ├── ai_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── ui/                      # UI layer
│   ├── pages/               # Pages
│   │   ├── home/
│   │   ├── create/
│   │   ├── edit/
│   │   ├── detail/
│   │   ├── settings/        # To be created
│   │   └── auth/            # To be created
│   ├── theme/               # Theme configuration
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   └── widgets/             # Reusable widgets
│       ├── flip_diary_card.dart
│       └── starry_background.dart
├── utils/                   # Utilities
│   └── mock_data.dart
└── main.dart               # App entry point
```

## 🎨 Design System

### Typography
- **Primary Font**: Cormorant Garamond (elegant serif for English)
- **CJK Font**: Noto Sans JP (clean sans-serif for Japanese/Chinese)
- **Code Font**: Source Code Pro (monospace)

### Colors
Each theme has:
- Primary color (main brand color)
- Secondary color (accent)
- Tertiary color (highlights)
- Surface colors (backgrounds)
- Error color

### Spacing
- Base unit: 4px
- Small: 8px, 12px
- Medium: 16px, 20px, 24px
- Large: 32px, 40px, 48px

### Border Radius
- Small: 8px, 10px
- Medium: 12px, 16px
- Large: 20px, 24px

### Shadows
- Card shadow: `BoxShadow(color: black.withOpacity(0.1), blurRadius: 20)`
- Hover shadow: `BoxShadow(color: black.withOpacity(0.15), blurRadius: 24)`

## 🔧 Key Technologies

### Frontend
- **Flutter**: UI framework
- **Riverpod**: State management
- **Hive**: Local database
- **Google Fonts**: Typography
- **Flutter Markdown**: Markdown rendering
- **Intl**: Internationalization

### Backend (to be implemented)
- **Firebase Authentication**: User management
- **Cloud Firestore**: Database
- **Firebase Cloud Functions**: Serverless backend
- **Gemini API**: AI text generation

## 📝 Coding Conventions

### File Naming
- Snake case: `diary_detail_page.dart`
- Private files: `_internal_widget.dart`

### Class Naming
- PascalCase: `DiaryDetailPage`
- Private classes: `_InternalWidget`

### Variable Naming
- camelCase: `diaryList`, `currentTheme`
- Private variables: `_controller`, `_isHovered`

### Widget Structure
```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Build UI
    return Container();
  }
  
  // Helper methods
  Widget _buildSection() {}
}
```

### State Management
- Use Riverpod providers for global state
- Use StatefulWidget for local animations
- Keep business logic in repositories/services

## 🐛 Common Issues

### Issue: Hot reload not working
**Solution**: Restart the app completely

### Issue: Theme not updating
**Solution**: Ensure `themeProvider` is watched in `main.dart`

### Issue: Hive type error
**Solution**: Run `flutter packages pub run build_runner build`

### Issue: Import errors
**Solution**: Run `flutter pub get`

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Gemini API](https://ai.google.dev/)
- [Google Fonts](https://fonts.google.com/)
