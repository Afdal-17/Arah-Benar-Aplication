import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage>
    with SingleTickerProviderStateMixin {
  int count = 0;
  int target = 33;
  String selectedDzikir = "Subhanallah";
  late AnimationController _tapController;

  final List<Map<String, dynamic>> dzikirList = [
    {'name': 'Subhanallah', 'arabic': 'سُبْحَانَ اللَّهِ'},
    {'name': 'Alhamdulillah', 'arabic': 'الْحَمْدُ لِلَّهِ'},
    {'name': 'Allahu Akbar', 'arabic': 'اللَّهُ أَكْبَرُ'},
    {'name': 'La Ilaha Illallah', 'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ'},
    {'name': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ اللَّهَ'},
  ];

  String get selectedArabic =>
      dzikirList.firstWhere((d) => d['name'] == selectedDzikir)['arabic'];

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void increment() {
    _tapController.forward(from: 0);
    setState(() {
      count++;
      if (count >= target) {
        count = 0;
      }
    });
  }

  void reset() {
    setState(() => count = 0);
  }

  @override
  Widget build(BuildContext context) {
    double progress = count / target;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text("Tasbih Digital",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Dzikir selector
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF152238),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedDzikir,
                  dropdownColor: const Color(0xFF1B2838),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFFD4AF37)),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  items: dzikirList.map((dzikir) {
                    return DropdownMenuItem(
                      value: dzikir['name'] as String,
                      child: Text(dzikir['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDzikir = value!;
                      count = 0;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// Arabic text
              Text(
                selectedArabic,
                style: GoogleFonts.amiri(
                  color: const Color(0xFFD4AF37),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              /// Circular progress + counter
              GestureDetector(
                onTap: increment,
                child: AnimatedBuilder(
                  animation: _tapController,
                  builder: (_, child) {
                    final scale = 1.0 - (_tapController.value * 0.05);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Background ring
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: _CircularProgressPainter(
                            progress: progress,
                            bgColor: const Color(0xFF152238),
                            fgColor: const Color(0xFFD4AF37),
                          ),
                        ),

                        /// Inner circle
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1B3A4B),
                                Color(0xFF152238),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$count",
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "dari $target",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white38,
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

              const SizedBox(height: 20),

              Text(
                "Ketuk untuk berdzikir",
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              /// Target selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [33, 99, 100].map((t) {
                  final isActive = target == t;
                  return GestureDetector(
                    onTap: () => setState(() {
                      target = t;
                      count = 0;
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF152238),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFFD4AF37)
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        '$t×',
                        style: GoogleFonts.poppins(
                          color: isActive
                              ? const Color(0xFF0D1B2A)
                              : Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// Reset
              TextButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                label: Text(
                  "Reset",
                  style: GoogleFonts.poppins(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular progress painter
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fgColor;

  _CircularProgressPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}