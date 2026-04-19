import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/qibla_utils.dart';

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage>
    with SingleTickerProviderStateMixin {
  double? _qiblaDirection;
  double? _distanceToKaaba;
  String _locationInfo = "Mengambil lokasi...";
  double _smoothHeading = 0;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _locationInfo = "Izin lokasi ditolak");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _qiblaDirection =
            calculateQiblaDirection(position.latitude, position.longitude);
        _distanceToKaaba =
            calculateDistanceToKaaba(position.latitude, position.longitude);
        _locationInfo =
            "${position.latitude.toStringAsFixed(4)}°, ${position.longitude.toStringAsFixed(4)}°";
      });
    } catch (e) {
      setState(() => _locationInfo = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('Arah Kiblat',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _qiblaDirection == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _locationInfo,
                    style: GoogleFonts.poppins(color: Colors.white60),
                  ),
                ],
              ),
            )
          : StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                double heading = 0;

                if (snapshot.hasData && snapshot.data!.heading != null) {
                  heading = snapshot.data!.heading!;
                }

                // Smooth rotation
                double diff = heading - _smoothHeading;
                if (diff > 180) diff -= 360;
                if (diff < -180) diff += 360;
                _smoothHeading += diff * 0.15;

                final qiblaAngle =
                    (_qiblaDirection! - _smoothHeading) * (pi / 180);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      /// Info card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF152238),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoColumn(
                              "Arah Kiblat",
                              "${_qiblaDirection!.toStringAsFixed(1)}°",
                              Icons.explore,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white12,
                            ),
                            _infoColumn(
                              "Jarak Ka'bah",
                              "${_distanceToKaaba!.toStringAsFixed(0)} km",
                              Icons.straighten,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// Compass
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CustomPaint(
                          painter: _CompassPainter(
                            heading: -_smoothHeading * (pi / 180),
                            qiblaAngle: qiblaAngle,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Direction text
                      Text(
                        'Putar perangkat ke arah jarum emas',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              color: Color(0xFF00BFA6), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _locationInfo,
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      if (!snapshot.hasData || snapshot.data!.heading == null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Sensor kompas tidak terdeteksi. Kompas mungkin tidak tersedia di perangkat ini.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.orange.shade200,
                                    fontSize: 12,
                                  ),
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

  Widget _infoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Custom Compass Painter — no image asset needed
class _CompassPainter extends CustomPainter {
  final double heading;
  final double qiblaAngle;

  _CompassPainter({required this.heading, required this.qiblaAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(heading);

    // Outer ring
    final outerRingPaint = Paint()
      ..color = const Color(0xFF1B3A4B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius, outerRingPaint);

    // Outer ring border
    final outerBorderPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, radius, outerBorderPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = const Color(0xFF0D1B2A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.75, innerPaint);

    final innerBorderPaint = Paint()
      ..color = const Color(0xFF00BFA6).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset.zero, radius * 0.75, innerBorderPaint);

    // Degree markings
    for (int i = 0; i < 360; i += 5) {
      final angle = i * pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      final startR = isCardinal
          ? radius * 0.78
          : isMajor
              ? radius * 0.82
              : radius * 0.88;
      final endR = radius * 0.92;

      final paint = Paint()
        ..color = isCardinal
            ? const Color(0xFFD4AF37)
            : isMajor
                ? Colors.white54
                : Colors.white24
        ..strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.5 : 0.8);

      canvas.drawLine(
        Offset(cos(angle) * startR, sin(angle) * startR),
        Offset(cos(angle) * endR, sin(angle) * endR),
        paint,
      );
    }

    // Cardinal direction labels
    final directions = {
      0: 'N',
      90: 'E',
      180: 'S',
      270: 'W',
    };
    directions.forEach((deg, label) {
      final angle = (deg - 90) * pi / 180;
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? const Color(0xFFEF5350) : const Color(0xFFD4AF37),
            fontSize: deg == 0 ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final pos = Offset(
        cos(angle) * radius * 0.68 - textPainter.width / 2,
        sin(angle) * radius * 0.68 - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    });

    // North arrow (red triangle)
    final northAngle = -pi / 2;
    final northPath = Path()
      ..moveTo(cos(northAngle) * radius * 0.55, sin(northAngle) * radius * 0.55)
      ..lineTo(
          cos(northAngle - 0.12) * radius * 0.4, sin(northAngle - 0.12) * radius * 0.4)
      ..lineTo(
          cos(northAngle + 0.12) * radius * 0.4, sin(northAngle + 0.12) * radius * 0.4)
      ..close();

    final northPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.fill;
    canvas.drawPath(northPath, northPaint);

    // Center dot
    final centerDotPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 6, centerDotPaint);

    canvas.restore();

    // Qibla arrow (gold) — drawn AFTER restoring canvas so it doesn't rotate with heading
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final qAngle = qiblaAngle - pi / 2;
    final qPath = Path()
      ..moveTo(cos(qAngle) * radius * 0.6, sin(qAngle) * radius * 0.6)
      ..lineTo(
          cos(qAngle - 0.1) * radius * 0.42, sin(qAngle - 0.1) * radius * 0.42)
      ..lineTo(
          cos(qAngle + 0.1) * radius * 0.42, sin(qAngle + 0.1) * radius * 0.42)
      ..close();

    final qPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawPath(qPath, qPaint);

    // Qibla glow
    final qGlowPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cos(qAngle) * radius * 0.6, sin(qAngle) * radius * 0.6),
      10,
      qGlowPaint,
    );

    // Ka'bah icon indicator
    final kaabaTextPainter = TextPainter(
      text: const TextSpan(
        text: '🕋',
        style: TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    kaabaTextPainter.layout();
    kaabaTextPainter.paint(
      canvas,
      Offset(
        cos(qAngle) * radius * 0.95 - kaabaTextPainter.width / 2,
        sin(qAngle) * radius * 0.95 - kaabaTextPainter.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading || oldDelegate.qiblaAngle != qiblaAngle;
}