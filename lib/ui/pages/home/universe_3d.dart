import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/models/diary.dart';
import '../../widgets/planet_widget.dart';

class Universe3D extends StatefulWidget {
  final List<Diary> diaries;
  final Function(Diary) onDiaryTap;

  const Universe3D({
    super.key,
    required this.diaries,
    required this.onDiaryTap,
  });

  @override
  State<Universe3D> createState() => _Universe3DState();
}

class _Universe3DState extends State<Universe3D> with TickerProviderStateMixin {
  // 3D Points (Spherical Coordinates)
  final List<_Point3D> _points = [];
  
  // Camera/Rotation
  double _rotationX = 0;
  double _rotationY = 0;
  double _baseScale = 0.8; // Start slightly zoomed out
  String? _focusedDiaryId;
  
  late AnimationController _orbitController;
  
  // Constants
  static const double _radius = 500.0; // Increased radius for more space
  static const double _fov = 600.0; // Wider FOV

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // Very slow orbit
    )..repeat();
    
    _generatePoints();
  }

  @override
  void didUpdateWidget(Universe3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.diaries.length != oldWidget.diaries.length) {
      _generatePoints();
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  void _generatePoints() {
    _points.clear();
    final random = Random();
    
    for (var diary in widget.diaries) {
      // Spherical coordinates
      final theta = random.nextDouble() * 2 * pi;
      final phi = acos(2 * random.nextDouble() - 1);
      // Distribute between 0.4R and R, pushing them a bit further out
      final r = _radius * (0.4 + random.nextDouble() * 0.6); 

      _points.add(_Point3D(
        diary: diary,
        theta: theta,
        phi: phi,
        r: r,
        size: 30.0 + random.nextDouble() * 20.0, // Slightly smaller planets
      ));
    }
  }

  void _handleScale(ScaleUpdateDetails details) {
    setState(() {
      // Handle Rotation (Pan)
      if (details.scale == 1.0) {
        _rotationY += details.focalPointDelta.dx * 0.005; // Slower rotation
        _rotationX -= details.focalPointDelta.dy * 0.005;
      }
      
      // Handle Zoom (Scale)
      if (details.scale != 1.0) {
        // For trackpads, scaleDelta is often small, so we accumulate
        // But ScaleUpdateDetails.scale is cumulative for the gesture.
        // We just clamp it to a reasonable range.
        _baseScale = (_baseScale * details.scale).clamp(0.2, 4.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        // 1. Calculate Cartesian & Rotate
        final rotatedPoints = _points.map((p) {
          // Orbit rotation (changes over time)
          final orbitTheta = p.theta + _orbitController.value * 2 * pi;
          
          // Spherical to Cartesian
          double x = p.r * sin(p.phi) * cos(orbitTheta);
          double y = p.r * sin(p.phi) * sin(orbitTheta);
          double z = p.r * cos(p.phi);

          // Camera Rotation
          // Rotate around Y axis
          double x1 = x * cos(_rotationY) - z * sin(_rotationY);
          double z1 = x * sin(_rotationY) + z * cos(_rotationY);
          
          // Rotate around X axis
          double y2 = y * cos(_rotationX) - z1 * sin(_rotationX);
          double z2 = y * sin(_rotationX) + z1 * cos(_rotationX);

          return _ProjectedPoint(
            original: p,
            x: x1,
            y: y2,
            z: z2,
          );
        }).toList();

        // 2. Sort by Z (depth)
        rotatedPoints.sort((a, b) => b.z.compareTo(a.z));

        return GestureDetector(
          onScaleUpdate: _handleScale,
          onTap: () {
            setState(() {
              _focusedDiaryId = null;
            });
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // 渲染所有行星
                ...rotatedPoints.map((p) {
                  // 3. Perspective Projection
                  final scale = (_fov / (_fov + p.z)) * _baseScale;
                  final screenX = centerX + p.x * scale;
                  final screenY = centerY + p.y * scale;
                  
                  if (scale < 0) return const SizedBox();

                  final isFocused = _focusedDiaryId == p.original.diary.id;
                  final displayScale = isFocused ? scale * 2.5 : scale;

                  return Positioned(
                    left: screenX - (p.original.size * displayScale) / 2,
                    top: screenY - (p.original.size * displayScale) / 2,
                    child: AnimatedScale(
                      scale: displayScale,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: PlanetWidget(
                        key: ValueKey(p.original.diary.id),
                        diary: p.original.diary,
                        size: p.original.size,
                        depth: scale,
                        onTap: () => widget.onDiaryTap(p.original.diary),
                        onLongPress: () {
                          setState(() {
                            _focusedDiaryId = p.original.diary.id;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
                
                // 中心恒星（太阳） - 始终在中心
                Positioned(
                  left: centerX - 40,
                  top: centerY - 40,
                  child: PlanetWidget(
                    key: const ValueKey('central_star'),
                    diary: widget.diaries.isNotEmpty 
                        ? widget.diaries.first 
                        : Diary(
                            id: 'star',
                            date: DateTime.now(),
                            type: 'star',
                            rawContent: 'Our Star',
                            style: 'warm',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                    size: 80,
                    depth: 1.0,
                    isStar: true, // 标记为恒星
                    onTap: () {}, // 恒星不可点击
                    onLongPress: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Point3D {
  final Diary diary;
  final double theta;
  final double phi;
  final double r;
  final double size;

  _Point3D({
    required this.diary,
    required this.theta,
    required this.phi,
    required this.r,
    required this.size,
  });
}

class _ProjectedPoint {
  final _Point3D original;
  final double x;
  final double y;
  final double z;

  _ProjectedPoint({
    required this.original,
    required this.x,
    required this.y,
    required this.z,
  });
}
