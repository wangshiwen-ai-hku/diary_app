import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/diary.dart';
import 'data/repositories/local_diary_repository.dart';
import 'data/providers/theme_provider.dart';
import 'core/config_manager.dart';
import 'ui/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DiaryAdapter());

  // Initialize config manager
  await ConfigManager().init();

  // Initialize mock data (development only)
  final repository = LocalDiaryRepository();
  await repository.initMockData(count: 10);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Our Diary',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
