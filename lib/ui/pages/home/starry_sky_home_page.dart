import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/diary.dart';
import '../../../data/providers/diary_provider.dart';
import '../../theme/theme_colors.dart';
import '../../widgets/starry_background.dart';
import 'universe_3d.dart';
import '../detail/diary_detail_page.dart';
import '../create/create_diary_page.dart';
import '../settings/settings_page.dart';

class StarrySkyHomePage extends ConsumerStatefulWidget {
  const StarrySkyHomePage({super.key});

  @override
  ConsumerState<StarrySkyHomePage> createState() => _StarrySkyHomePageState();
}

class _StarrySkyHomePageState extends ConsumerState<StarrySkyHomePage> {
  @override
  Widget build(BuildContext context) {
    final diaries = ref.watch(diariesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Our Universe',
          style: GoogleFonts.cormorantGaramond( // Romantic script font
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: StarryBackground(
        child: Stack(
          children: [
            // 3D Universe
            if (diaries.isNotEmpty)
              Universe3D(
                diaries: diaries,
                onDiaryTap: (diary) => _openDiary(context, diary),
              ),
            
            // Empty state
            if (diaries.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The universe is empty...\nAdd your first planet.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDiaryPage()),
          );
          if (result == true) {
            ref.read(diariesProvider.notifier).refresh();
          }
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 0),
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.1),
                child: const Icon(
                  Icons.add,
                  color: Colors.white70,
                  size: 28,
                  // no border

                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openDiary(BuildContext context, Diary diary) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DiaryDetailPage(diary: diary),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}


