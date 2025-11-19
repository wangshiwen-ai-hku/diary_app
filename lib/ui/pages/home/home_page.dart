import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          centerTitle: true,
          title: Text(
            'Our Story',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 1.0,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                size: 24,
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
            const SizedBox(width: 16),
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
          icon: const Icon(Icons.edit_outlined),
          label: Text(
            'WRITE',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 4,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Your Story Begins Here',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Capture your first memory together',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.5,
              height: 1.5,
            ),
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
    _pageController = PageController(viewportFraction: 0.85);
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
        const Spacer(flex: 1),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.diaries.length,
            physics: const BouncingScrollPhysics(),
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
        const Spacer(flex: 2),
      ],
    );
  }
}
