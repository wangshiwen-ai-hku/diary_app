import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/diary.dart';
import '../../theme/theme_colors.dart';
import '../edit/edit_diary_page.dart';
import '../../widgets/starry_background.dart';

class DiaryDetailPage extends ConsumerStatefulWidget {
  final Diary diary;

  const DiaryDetailPage({super.key, required this.diary});

  @override
  ConsumerState<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends ConsumerState<DiaryDetailPage> {
  late Diary _currentDiary;

  @override
  void initState() {
    super.initState();
    _currentDiary = widget.diary;
  }

  Future<void> _editDiary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiaryPage(diary: _currentDiary),
      ),
    );

    if (result == true && mounted) {
      // In a real app, we would reload the diary from the DB here.
      // For now, we assume the provider updates or we pass the updated diary back.
      // Since we don't have a direct "getById" here easily without repo, 
      // we rely on the list refresh or just pop. 
      // But to be safe, let's just pop for now or handle it if we had the repo.
      Navigator.pop(context); 
    }
  }

  Future<void> _shareDiary() async {
    final date = DateFormat('MMMM dd, yyyy').format(_currentDiary.date);
    final content = '''
$date

${_currentDiary.rawContent}

${_currentDiary.aiContent ?? ''}

---
From "Our Universe"
''';
    await Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMMM dd, yyyy').format(_currentDiary.date);
    final theme = Theme.of(context);

    return StarryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white70),
              onPressed: _editDiary,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white70),
              onPressed: _shareDiary,
            ),
          ],
        ),
        body: Stack(
          children: [
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          date,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTags(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Main Content Card (Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_currentDiary.aiContent != null) ...[
                              Text(
                                'The Story',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 24),
                              MarkdownBody(
                                data: _currentDiary.aiContent!,
                                styleSheet: MarkdownStyleSheet(
                                  p: GoogleFonts.lato(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                  h1: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                  h2: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                  blockquote: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  blockquoteDecoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.white.withOpacity(0.3), width: 4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Divider(color: Colors.white.withOpacity(0.1)),
                              const SizedBox(height: 24),
                            ],

                            Text(
                              'Original Note',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentDiary.rawContent,
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.white.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        if (_currentDiary.mood != null)
          _buildTag(
            icon: Icons.sentiment_satisfied_alt_outlined,
            label: _currentDiary.mood!,
          ),
        if (_currentDiary.location != null)
          _buildTag(
            icon: Icons.location_on_outlined,
            label: _currentDiary.location!,
          ),
        _buildTag(
          icon: _getTypeIcon(_currentDiary.type),
          label: _getTypeLabel(_currentDiary.type),
        ),
      ],
    );
  }

  Widget _buildTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'sweet': return Icons.favorite_outline;
      case 'highlight': return Icons.star_outline;
      case 'quarrel': return Icons.bolt_outlined;
      case 'travel': return Icons.flight_takeoff_outlined;
      default: return Icons.edit_outlined;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'sweet': return 'Sweet';
      case 'highlight': return 'Highlight';
      case 'quarrel': return 'Challenge';
      case 'travel': return 'Travel';
      default: return 'Daily';
    }
  }
}
