import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/diary.dart';

class PlanetWidget extends StatefulWidget {
  final Diary diary;
  final double size;
  final double depth; // 0.0 (far) to 1.0 (near)
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isStar; // 是否为恒星

  const PlanetWidget({
    super.key,
    required this.diary,
    required this.size,
    required this.depth, // Normalized depth for effects
    required this.onTap,
    required this.onLongPress,
    this.isStar = false,
  });

  @override
  State<PlanetWidget> createState() => _PlanetWidgetState();
}

class _PlanetWidgetState extends State<PlanetWidget> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _twinkleController;
  late AnimationController _asteroidController;
  late AnimationController _coreFlickerController;
  final List<_Asteroid> _asteroids = [];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20 + Random().nextInt(20)), // Random slow rotation
    )..repeat();

    _twinkleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + Random().nextInt(1000)),
    )..repeat(reverse: true);

    // 小行星带旋转控制器（仅用于恒星）
    _asteroidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // 恒星核心闪烁控制器
    _coreFlickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // 生成小行星
    if (widget.isStar) {
      _generateAsteroids();
    }
  }

  void _generateAsteroids() {
    final random = Random();
    for (int i = 0; i < 15; i++) {
      _asteroids.add(_Asteroid(
        angle: random.nextDouble() * 2 * pi,
        distance: 0.6 + random.nextDouble() * 0.3, // 0.6-0.9 of radius
        size: 2 + random.nextDouble() * 3,
        speed: 0.5 + random.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _twinkleController.dispose();
    _asteroidController.dispose();
    _coreFlickerController.dispose();
    super.dispose();
  }

  Color _getPlanetColor(String type) {
    switch (type) {
      case 'sweet': return const Color(0xFFE8A0BF); // 更真实的粉红色
      case 'highlight': return const Color(0xFFD4AF37); // 金色
      case 'quarrel': return const Color(0xFF7B8FA3); // 蓝灰色
      case 'travel': return const Color(0xFF6B8E7F); // 森林绿
      default: return const Color(0xFFC0C0C0); // 银色
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate visual effects based on depth
    final scale = widget.depth;
    final isFar = scale < 0.8;
    final opacity = (scale * 0.8).clamp(0.3, 1.0);
    final blur = isFar ? (1.0 - scale) * 3.0 : 0.0;
    
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Planet/Star with effects
          Opacity(
            opacity: opacity,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: widget.isStar ? _buildStar(scale, opacity) : _buildPlanet(scale, opacity),
              ),
            ),
          ),
          
          // Label (Title & Date)
          // Only show if VERY close (scale > 1.2)
          if (scale > 1.2 && scale < 2.0)
            Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date
                          Text(
                            DateFormat('MM.dd').format(widget.diary.date),
                            style: GoogleFonts.lato(
                              fontSize: 10 * scale,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          // Divider
                          Container(
                            width: 1,
                            height: 10 * scale,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          SizedBox(width: 8 * scale),
                          // Content
                          Text(
                            _truncateText(widget.diary.rawContent),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 6 * scale,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建普通行星
  Widget _buildPlanet(double scale, double opacity) {
    final color = _getPlanetColor(widget.diary.type);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _twinkleController]),
      builder: (context, child) {
        final twinkle = 0.8 + _twinkleController.value * 0.2;
        
        return Stack(
          children: [
            // 1. Rotating Surface (The Planet Itself)
            Transform.rotate(
              angle: _rotationController.value * 2 * pi,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            
            // 2. Static Lighting Overlay (Shadow & Highlight)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.4 * twinkle),
                    Colors.white.withOpacity(0.1 * twinkle),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  center: const Alignment(-0.5, -0.5),
                  radius: 1.35,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4 * opacity * twinkle),
                    blurRadius: 25 * scale,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            
            // 3. Subtle rim light (gives depth)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15 * twinkle),
                  width: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建恒星
  Widget _buildStar(double scale, double opacity) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _coreFlickerController,
        _asteroidController,
      ]),
      builder: (context, child) {
        final coreFlicker = 0.7 + _coreFlickerController.value * 0.3;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. 外层辐射光环（最大）
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.3 * coreFlicker),
                      blurRadius: 80 * scale,
                      spreadRadius: 20 * scale,
                    ),
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2 * coreFlicker),
                      blurRadius: 60 * scale,
                      spreadRadius: 10 * scale,
                    ),
                  ],
                ),
              ),
            ),
            
            // 2. 中层辐射光环
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.yellow.withOpacity(0.15 * coreFlicker),
                      Colors.orange.withOpacity(0.1 * coreFlicker),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            
            // 3. 小行星带
            ...(_asteroids.map((asteroid) {
              final angle = asteroid.angle + _asteroidController.value * 2 * pi * asteroid.speed;
              final radius = widget.size / 2 * asteroid.distance;
              final x = cos(angle) * radius;
              final y = sin(angle) * radius;
              
              return Positioned(
                left: widget.size / 2 + x - asteroid.size / 2,
                top: widget.size / 2 + y - asteroid.size / 2,
                child: Container(
                  width: asteroid.size,
                  height: asteroid.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            }).toList()),
            
            // 4. 恒星核心（旋转的等离子体效果）
            Positioned.fill(
              child: Transform.rotate(
                angle: _rotationController.value * 2 * pi * 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFFFFFFFF), // 白色
                        const Color(0xFFFFF8DC), // 奶油色
                        const Color(0xFFFFD700), // 金色
                        const Color(0xFFFFA500), // 橙色
                        const Color(0xFFFFFFFF), // 白色
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            
            // 5. 核心闪烁高光层
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.9 * coreFlicker),
                      Colors.yellow.withOpacity(0.7 * coreFlicker),
                      Colors.orange.withOpacity(0.5 * coreFlicker),
                      Colors.deepOrange.withOpacity(0.3 * coreFlicker),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            
            // 6. 半透明边框（增强立体感）
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3 * coreFlicker),
                    width: 2.5,
                  ),
                ),
              ),
            ),
            
            // 7. 内层边框（细节）
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.yellow.withOpacity(0.2 * coreFlicker),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _truncateText(String content) {
    final firstLine = content.split('\n').first;
    if (firstLine.length > 10) {
      return '${firstLine.substring(0, 10)}...';
    }
    return firstLine;
  }
}

// 小行星数据类
class _Asteroid {
  final double angle;     // 初始角度
  final double distance;  // 距离恒星中心的距离（相对于半径）
  final double size;      // 小行星大小
  final double speed;     // 旋转速度倍数

  _Asteroid({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
  });
}
