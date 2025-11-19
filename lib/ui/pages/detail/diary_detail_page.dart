import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/diary.dart';
import '../../../data/providers/theme_provider.dart';
import '../../theme/theme_colors.dart';
import '../edit/edit_diary_page.dart';
import 'package:intl/intl.dart';
import '../../widgets/starry_background.dart';

class DiaryDetailPage extends ConsumerStatefulWidget {
  final Diary diary;

  const DiaryDetailPage({super.key, required this.diary});

  @override
  ConsumerState<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends ConsumerState<DiaryDetailPage> {
  late Diary _currentDiary;
  bool _showSource = false;

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
      setState(() {
        // Refresh from database
      });
    }
  }

  Future<void> _shareDiary() async {
    final date = DateFormat('MMMM dd, yyyy').format(_currentDiary.date);
    final content = '''
$date

${_currentDiary.rawContent}

${_currentDiary.aiContent ?? ''}

---
From "Our Diary"
''';

    try {
      await Share.share(content);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeName = ref.watch(themeNameProvider);
    final themeColors = SystemThemeColors.getThemeColors(themeName);
    final isDark = theme.brightness == Brightness.dark;
    final date = DateFormat('MMMM dd, yyyy').format(_currentDiary.date);

    return StarryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(date),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editDiary,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareDiary,
              tooltip: 'Share',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'copy_raw') {
                  _copyToClipboard(_currentDiary.rawContent);
                } else if (value == 'copy_ai') {
                  _copyToClipboard(_currentDiary.aiContent ?? '');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'copy_raw',
                  child: Text('Copy raw content'),
                ),
                const PopupMenuItem(
                  value: 'copy_ai',
                  child: Text('Copy AI content'),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? const Color(0xFF1A1A2E).withOpacity(0.85)
                          : const Color(0xFFFAF9F6).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeColors.primary.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColors.primary.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTypeIcon(_currentDiary.type, themeColors),
                            const SizedBox(width: 12),
                            Text(
                              _getTypeTitle(_currentDiary.type),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: themeColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        if (_currentDiary.mood != null || _currentDiary.location != null) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              if (_currentDiary.mood != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sentiment_satisfied_alt_outlined,
                                      size: 18,
                                      color: themeColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getMoodText(_currentDiary.mood!),
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        color: isDark 
                                            ? themeColors.light
                                            : themeColors.dark,
                                      ),
                                    ),
                                  ],
                                ),
                              if (_currentDiary.location != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: themeColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _currentDiary.location!,
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        color: isDark 
                                            ? themeColors.light
                                            : themeColors.dark,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Raw content section
                  _buildSection(
                    themeColors: themeColors,
                    isDark: isDark,
                    title: 'Your Prompt',
                    icon: Icons.edit_note_outlined,
                    color: themeColors.primary,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? themeColors.dark.withOpacity(0.15)
                            : themeColors.light.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentDiary.rawContent,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          height: 1.9,
                          color: isDark 
                              ? themeColors.light
                              : themeColors.dark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // AI content section
                  if (_currentDiary.aiContent != null) ...[
                    const SizedBox(height: 32),
                    _buildSection(
                      themeColors: themeColors,
                      isDark: isDark,
                      title: 'AI Generated Diary',
                      icon: Icons.auto_awesome_outlined,
                      color: themeColors.medium,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle source/preview button
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showSource = !_showSource;
                                });
                              },
                              icon: Icon(
                                _showSource ? Icons.visibility : Icons.code,
                                size: 16,
                              ),
                              label: Text(_showSource ? 'Preview' : 'Source'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  themeColors.primary.withOpacity(0.08),
                                  themeColors.light.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: themeColors.primary.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: _showSource
                                ? SelectableText(
                                    _currentDiary.aiContent!,
                                    style: GoogleFonts.sourceCodePro(
                                      fontSize: 14,
                                      height: 1.7,
                                      color: isDark 
                                          ? themeColors.light
                                          : themeColors.dark,
                                    ),
                                  )
                                : MarkdownBody(
                                    data: _currentDiary.aiContent!,
                                    styleSheet: MarkdownStyleSheet(
                                      p: GoogleFonts.lato(
                                        fontSize: 17,
                                        height: 1.9,
                                        color: isDark 
                                            ? themeColors.light
                                            : themeColors.dark,
                                        letterSpacing: 0.3,
                                      ),
                                      h1: GoogleFonts.playfairDisplay(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                        color: themeColors.primary,
                                      ),
                                      h2: GoogleFonts.playfairDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                        color: themeColors.medium,
                                      ),
                                      h3: GoogleFonts.playfairDisplay(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                        color: themeColors.medium,
                                      ),
                                      blockquotePadding: const EdgeInsets.all(18),
                                      blockquoteDecoration: BoxDecoration(
                                        color: themeColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border(
                                          left: BorderSide(
                                            color: themeColors.primary,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      code: GoogleFonts.sourceCodePro(
                                        fontSize: 14,
                                        backgroundColor: isDark 
                                            ? themeColors.dark.withOpacity(0.3)
                                            : themeColors.light.withOpacity(0.5),
                                        color: isDark 
                                            ? themeColors.light
                                            : themeColors.dark,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeColors themeColors,
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }

  Widget _buildTypeIcon(String type, ThemeColors themeColors) {
    IconData icon;
    Color color;

    switch (type) {
      case 'sweet':
        icon = Icons.favorite_outline;
        color = themeColors.primary;
        break;
      case 'highlight':
        icon = Icons.star_outline;
        color = themeColors.light;
        break;
      case 'quarrel':
        icon = Icons.crisis_alert_outlined;
        color = themeColors.dark;
        break;
      case 'travel':
        icon = Icons.flight_takeoff_outlined;
        color = themeColors.medium;
        break;
      default:
        icon = Icons.event_note_outlined;
        color = themeColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }

  String _getTypeTitle(String type) {
    switch (type) {
      case 'sweet':
        return 'Sweet Moment';
      case 'highlight':
        return 'Special Day';
      case 'quarrel':
        return 'Challenge';
      case 'travel':
        return 'Journey';
      default:
        return 'Daily Life';
    }
  }

  String _getMoodText(String mood) {
    switch (mood) {
      case 'happy':
        return 'Feeling Happy';
      case 'sweet':
        return 'Feeling Sweet';
      case 'miss':
        return 'Feeling Nostalgic';
      case 'excited':
        return 'Feeling Excited';
      case 'calm':
        return 'Feeling Calm';
      case 'sad':
        return 'Feeling Sad';
      case 'angry':
        return 'Feeling Upset';
      default:
        return 'Feeling Neutral';
    }
  }
}

