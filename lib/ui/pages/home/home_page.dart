import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/diary.dart';
import '../../../data/providers/diary_provider.dart';
import '../../../data/providers/theme_provider.dart';
import '../../widgets/starry_background.dart';
import '../../widgets/sliding_diary_card.dart';
import '../create/create_diary_page.dart';
import '../detail/diary_detail_page.dart';
import '../settings/settings_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaries = ref.watch(diariesProvider);
    final theme = Theme.of(context);

    return StarryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Icon(
                Icons.favorite,
                color: theme.colorScheme.primary.withOpacity(0.8),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Our Diary',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.95)
                      : const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.85)
                    : const Color(0xFF4A4A4A),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              tooltip: 'Settings',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: diaries.isEmpty
              ? _buildEmptyState(context)
              : _buildDiaryGrid(context, ref, diaries),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateDiaryPage(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Entry'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Entries Yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start your journey by creating\nyour first diary entry',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateDiaryPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create First Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryGrid(
    BuildContext context,
    WidgetRef ref,
    List<Diary> diaries,
  ) {
    return _SlidingDiaryContainer(
      diaries: diaries,
      onFullscreen: (diary) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DiaryDetailPage(diary: diary),
          ),
        );
      },
    );
  }
}

class _SlidingDiaryContainer extends StatefulWidget {
  final List<Diary> diaries;
  final Function(Diary) onFullscreen;

  const _SlidingDiaryContainer({
    required this.diaries,
    required this.onFullscreen,
  });

  @override
  State<_SlidingDiaryContainer> createState() => _SlidingDiaryContainerState();
}

class _SlidingDiaryContainerState extends State<_SlidingDiaryContainer> {
  late PageController _pageController;
  double _pageOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.84);
    _pageController.addListener(() {
      setState(() => _pageOffset = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
          child: Text(
            'Your Memories',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.95)
                  : const Color(0xFF2D2D2D),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.diaries.length,
            itemBuilder: (context, index) {
              final diary = widget.diaries[index];
              return SlidingDiaryCard(
                diary: diary,
                offset: _pageOffset - index,
                onFullscreen: () => widget.onFullscreen(diary),
              );
            },
          ),
        ),
      ],
    );
  }
}
