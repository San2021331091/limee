import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallpaper/home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _particleController;
  late final AnimationController _ringController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringProgress;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineProgress;
  late final Animation<double> _bgGradient;

  static const String _appName = "Limee";
  static const String _tagline = "Wallpapers that breathe.";

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _bgGradient = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    _logoOpacity = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.05, 0.40),
    );

    _ringProgress = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.30, 0.70, curve: Curves.easeOutCubic),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 0.80),
    );

    _taglineProgress = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainController.forward();
    });

    // ✅ Navigate AFTER animation completes (better than delay)
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goHome();
      }
    });
  }

  void _goHome() {
    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionsBuilder: (context, animation, _, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, _) {
          final t = _bgGradient.value;

          final topColor =
              Color.lerp(const Color(0xFF0A0E27), const Color(0xFF1B1B4D), t)!;
          final midColor =
              Color.lerp(const Color(0xFF16213E), const Color(0xFF432874), t)!;
          final bottomColor =
              Color.lerp(const Color(0xFF0F3460), const Color(0xFF6D28D9), t)!;

          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [topColor, midColor, bottomColor],
              ),
            ),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: size,
                      painter: _ParticlePainter(_particleController.value),
                    );
                  },
                ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _ringController,
                              builder: (context, _) {
                                return Transform.rotate(
                                  angle: _ringController.value * 2 * math.pi,
                                  child: CustomPaint(
                                    size: const Size(180, 180),
                                    painter: _RingPainter(
                                      progress: _ringProgress.value,
                                    ),
                                  ),
                                );
                              },
                            ),

                            Opacity(
                              opacity: _logoOpacity.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6)
                                          .withOpacity(0.4),
                                      blurRadius: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Opacity(
                              opacity: _logoOpacity.value,
                              child: Transform.rotate(
                                angle: _logoRotation.value,
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.wallpaper),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      Opacity(
                        opacity: _titleOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _titleSlide.value),
                          child: const Text(
                            _appName,
                            style: TextStyle(
                              fontSize: 42,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _tagline.substring(
                          0,
                          (_tagline.length * _taglineProgress.value).floor(),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================= PARTICLES =================
class _ParticlePainter extends CustomPainter {
  final double t;
  final List<_Particle> particles =
      List.generate(30, (i) => _Particle(i));

  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = (p.x + t * p.vx) % 1 * size.width;
      final y = (p.y + t * p.vy) % 1 * size.height;

      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = Colors.white.withOpacity(p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.t != t;
}

class _Particle {
  final double x, y, size, opacity, vx, vy;

  _Particle(int seed)
      : x = math.Random(seed).nextDouble(),
        y = math.Random(seed + 1).nextDouble(),
        size = math.Random(seed + 2).nextDouble() * 2 + 1,
        opacity = math.Random(seed + 3).nextDouble(),
        vx = (math.Random(seed + 4).nextDouble() - 0.5) * 0.1,
        vy = math.Random(seed + 5).nextDouble() * 0.2;
}

// ================= RING =================
class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = SweepGradient(
        colors: [
          Colors.purple.withOpacity(progress),
          Colors.blue.withOpacity(progress),
          Colors.purple.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}