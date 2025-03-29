import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MouseSplashScreen(),
    );
  }
}

class MouseSplashScreen extends StatefulWidget {
  const MouseSplashScreen({super.key});

  @override
  _MouseSplashScreenState createState() => _MouseSplashScreenState();
}

class _MouseSplashScreenState extends State<MouseSplashScreen> {
  final List<Splash> splashes = [];
  Timer? _fadeTimer;

  void _updateSplash(Offset position) {
    setState(() {
      splashes.add(Splash(position));
      if (splashes.length > 20) {
        splashes.removeAt(0);
      }
    });
    _resetFadeTimer();
  }

  void _resetFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(milliseconds: 60), () {
      _fadeOutSplashes();
    });
  }

  void _fadeOutSplashes() {
    if (splashes.isNotEmpty) {
      setState(() {
        for (var splash in splashes) {
          splash.opacity -= 0.05;
        }
        splashes.removeWhere((s) => s.opacity <= 0);
      });
      _fadeTimer = Timer(const Duration(milliseconds: 100), _fadeOutSplashes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (event) => _updateSplash(event.position),
        onExit: (_) => _fadeOutSplashes(),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: SplashPainter(splashes)),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Splash {
  final Offset position;
  final double radius;
  final List<Offset> randomOffsets;
  double opacity;

  Splash(this.position)
    : radius = Random().nextDouble() * 30 + 20,
      opacity = 0.8,
      randomOffsets = List.generate(
        5,
        (index) =>
            position +
            Offset(
              Random().nextDouble() * 40 - 20,
              Random().nextDouble() * 40 - 20,
            ),
      );
}

class SplashPainter extends CustomPainter {
  final List<Splash> splashes;

  SplashPainter(this.splashes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    for (final splash in splashes) {
      paint.color = Colors.blue.withOpacity(splash.opacity);
      for (final offset in splash.randomOffsets) {
        canvas.drawCircle(offset, splash.radius * 1.3, paint);
      }
      canvas.drawCircle(splash.position, splash.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
