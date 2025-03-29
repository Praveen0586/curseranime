import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import "package:url_launcher/url_launcher.dart";

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Center(
          child: InkWell(
            onTap: () async {
              final Uri url = Uri.parse("https://github.com/Praveen0586");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Could not launch URL")));
              }
            },
            child: Container(
              // margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(14),
              //   border: Border.all(color: Colors.white, width: 0.7),
              // ),
              height: 40,
              width: 130,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 25,
                    width: 30, // Ensure the image has a proper width
                    decoration: BoxDecoration(
                      // color: Colors.red,
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/gimage.png",
                        ), // Corrected path
                        fit: BoxFit.cover, // Ensures image fits properly
                      ),
                    ),
                  ),
                  Text(
                    "Praveen0586",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

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

            Positioned.fill(
              child: Container(
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Move Your Cursor",
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                        color: Colors.grey,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
