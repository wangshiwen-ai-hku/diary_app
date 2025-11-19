import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/diary.dart';
import '../../data/providers/theme_provider.dart';
import '../theme/theme_colors.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class SlidingDiaryCard extends ConsumerStatefulWidget {
  final Diary diary;
  final double offset;
  final VoidCallback? onFullscreen;

  const SlidingDiaryCard({
    super.key,
    required this.diary,
    required this.offset,
    this.onFullscreen,
  });

  @override
  ConsumerState<SlidingDiaryCard> createState() => _SlidingDiaryCardState();
}

class _SlidingDiaryCardState extends ConsumerState<SlidingDiaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    double gauss = math.exp(-(math.pow((widget.offset.abs() - 0.5), 2) / 0.08));
    
    return GestureDetector(
      onTap: _flip,
      child: Transform.translate(
        offset: Offset(-32 * gauss * widget.offset.sign, 0),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * math.pi;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);

            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: angle <= math.pi / 2
                  ? _buildFront(context)
                  : Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _buildBack(context),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    final theme = Theme.of(context);
    final themeName = ref.watch(themeNameProvider);
    final themeColors = SystemThemeColors.getThemeColors(themeName);
    final date = DateFormat('MMMM dd, yyyy').format(widget.diary.date);
    final offset = widget.offset.abs();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1A1A2E).withOpacity(0.85)
                  : const Color(0xFFFAF9F6).withOpacity(0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: themeColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Parallax header section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: themeColors.getGradient(widget.diary.type),
                      ),
                    ),
                    alignment: Alignment(-offset.clamp(-1.0, 1.0), 0),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTypeTitle(widget.diary.type),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: themeColors.onPrimary,
                              letterSpacing: 1.2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            date,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: themeColors.onPrimary.withOpacity(0.9),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mood text
                        if (widget.diary.mood != null) ...[
                          Text(
                            _getMoodText(widget.diary.mood!),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark 
                                  ? themeColors.light
                                  : themeColors.dark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Style label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: themeColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getStyleLabel(widget.diary.style),
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: themeColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Tap hint
                        Center(
                          child: Text(
                            'TAP TO VIEW DIARY',
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark 
                                  ? themeColors.medium.withOpacity(0.7)
                                  : themeColors.medium,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    final theme = Theme.of(context);
    final themeName = ref.watch(themeNameProvider);
    final themeColors = SystemThemeColors.getThemeColors(themeName);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColors.primary.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 36,
            offset: const Offset(0, 18),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1A1A2E).withOpacity(0.90)
                  : const Color(0xFFFAF9F6).withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: themeColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeColors.primary.withOpacity(0.08),
                        themeColors.light.withOpacity(0.05),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: themeColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'DIARY CONTENT',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: themeColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.fullscreen_outlined,
                          color: themeColors.primary,
                          size: 24,
                        ),
                        onPressed: widget.onFullscreen,
                        tooltip: 'View fullscreen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          backgroundColor: themeColors.primary.withOpacity(0.15),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Markdown content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: MarkdownBody(
                      data: widget.diary.aiContent ?? widget.diary.rawContent,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.lato(
                          fontSize: 16,
                          height: 1.9,
                          color: isDark 
                              ? themeColors.light
                              : themeColors.dark,
                          letterSpacing: 0.3,
                        ),
                        h1: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: themeColors.primary,
                        ),
                        h2: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: themeColors.medium,
                        ),
                        blockquotePadding: const EdgeInsets.all(16),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  String _getStyleLabel(String style) {
    switch (style) {
      case 'warm':
        return 'WARM';
      case 'poetic':
        return 'POETIC';
      case 'real':
        return 'REALISTIC';
      case 'funny':
        return 'HUMOROUS';
      default:
        return 'CLASSIC';
    }
  }
}
