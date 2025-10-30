import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/models/diary.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class FlipDiaryCard extends StatefulWidget {
  final Diary diary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onFullscreen;

  const FlipDiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onDelete,
    this.onFullscreen,
  });

  @override
  State<FlipDiaryCard> createState() => _FlipDiaryCardState();
}

class _FlipDiaryCardState extends State<FlipDiaryCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _showFront = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: Listenable.merge([_animation, _hoverAnimation]),
          builder: (context, child) {
            final angle = _animation.value * math.pi;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle)
              ..scale(_hoverAnimation.value);

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
    final date = DateFormat('MMM dd, yyyy').format(widget.diary.date);

    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
            blurRadius: _isHovered ? 24 : 20,
            offset: Offset(0, _isHovered ? 8 : 6),
            spreadRadius: _isHovered ? 2 : 0,
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6).withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      date,
                      style: GoogleFonts.cormorantGaramond(
                        color: theme.colorScheme.primary.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildTypeIcon(widget.diary.type, theme),
                ],
              ),
              const SizedBox(height: 28),
              
              // Title from type
              Text(
                _getTypeTitle(widget.diary.type),
                style: GoogleFonts.cormorantGaramond(
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                  letterSpacing: 0.5,
                  color: const Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              
              // Mood indicator (kaomoji style)
              if (widget.diary.mood != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getMoodKaomoji(widget.diary.mood!),
                      style: GoogleFonts.notoSansJp(
                        fontSize: 15,
                        color: const Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              // Style indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStyleLabel(widget.diary.style),
                  style: GoogleFonts.cormorantGaramond(
                    color: theme.colorScheme.secondary.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Tap to flip hint
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flip_outlined,
                      size: 15,
                      color: const Color(0xFF6B6B6B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to view diary',
                      style: GoogleFonts.cormorantGaramond(
                        color: const Color(0xFF6B6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    )
    );
  }

  Widget _buildBack(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(_isHovered ? 0.2 : 0.15),
            blurRadius: _isHovered ? 28 : 24,
            offset: Offset(0, _isHovered ? 10 : 8),
            spreadRadius: _isHovered ? 3 : 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Header with fullscreen button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 20,
                        color: theme.colorScheme.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AI Diary',
                        style: GoogleFonts.cormorantGaramond(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.fullscreen_outlined,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        onPressed: widget.onFullscreen,
                        tooltip: 'View fullscreen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          padding: const EdgeInsets.all(9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Markdown content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: MarkdownBody(
                      data: widget.diary.aiContent ?? widget.diary.rawContent,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.cormorantGaramond(
                          fontSize: 15,
                          height: 1.8,
                          color: const Color(0xFF3A3A3A),
                          letterSpacing: 0.3,
                        ),
                        h1: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: const Color(0xFF2D2D2D),
                        ),
                        h2: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: const Color(0xFF2D2D2D),
                        ),
                        blockquotePadding: const EdgeInsets.all(14),
                        blockquoteDecoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        code: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: const Color(0xFF3A3A3A),
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

  Widget _buildTypeIcon(String type, ThemeData theme) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'sweet':
        icon = Icons.favorite_outline;
        color = Colors.pink.shade300;
        break;
      case 'highlight':
        icon = Icons.star_outline;
        color = Colors.amber.shade400;
        break;
      case 'quarrel':
        icon = Icons.crisis_alert_outlined;
        color = Colors.orange.shade400;
        break;
      case 'travel':
        icon = Icons.flight_takeoff_outlined;
        color = Colors.blue.shade400;
        break;
      default:
        icon = Icons.event_note_outlined;
        color = theme.colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
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

  String _getMoodKaomoji(String mood) {
    const moods = {
      'happy': '(◕‿◕) Happy',
      'sweet': '(｡♥‿♥｡) Sweet',
      'miss': '(｡•́︿•̀｡) Miss',
      'excited': '(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧ Excited',
      'calm': '(~‾▿‾)~ Calm',
      'sad': '(╥﹏╥) Sad',
      'angry': '(ಠ_ಠ) Upset',
    };
    return moods[mood] ?? '(・ω・) Neutral';
  }

  String _getStyleLabel(String style) {
    switch (style) {
      case 'warm':
        return 'WARM STYLE';
      case 'poetic':
        return 'POETIC STYLE';
      case 'real':
        return 'REALISTIC STYLE';
      case 'funny':
        return 'FUNNY STYLE';
      default:
        return 'DEFAULT STYLE';
    }
  }
}
