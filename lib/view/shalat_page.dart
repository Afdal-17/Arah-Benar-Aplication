import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/shalat_view_model.dart';

class ShalatPage extends StatefulWidget {
  const ShalatPage({super.key});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ShalatViewModel>().fetchTodayPrayer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShalatViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('Jadwal Shalat',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : vm.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat jadwal',
                        style: GoogleFonts.poppins(color: Colors.white60),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vm.error!,
                        style: GoogleFonts.poppins(
                            color: Colors.white38, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => vm.fetchTodayPrayer(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : vm.todayPrayer == null
                  ? Center(
                      child: Text(
                        'Tidak ada data',
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          /// Date header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1B3A4B),
                                  Color(0xFF152238),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  vm.todayPrayer!.dateReadable,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vm.todayPrayer!.hijriDate,
                                  style: GoogleFonts.amiri(
                                    color: const Color(0xFFD4AF37),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// Prayer time cards
                          ...vm.todayPrayer!.prayerList.map(
                            (entry) => _prayerCard(
                              entry.key,
                              entry.value,
                              _getIconForPrayer(entry.key),
                              _getColorForPrayer(entry.key),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _prayerCard(
      String name, String time, IconData icon, Color color) {
    final now = DateTime.now();

    final parts = time.split(':');
    final prayerMinutes =
        parts.length == 2 ? int.parse(parts[0]) * 60 + int.parse(parts[1]) : 0;
    final currentMinutes = now.hour * 60 + now.minute;

    final isPast = prayerMinutes < currentMinutes;
    final isCurrent = (prayerMinutes - currentMinutes).abs() < 30 &&
        prayerMinutes >= currentMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrent
            ? color.withOpacity(0.12)
            : const Color(0xFF152238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? color.withOpacity(0.4)
              : Colors.white.withOpacity(0.05),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                color: isPast ? Colors.white38 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: isCurrent ? color : (isPast ? Colors.white38 : Colors.white),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForPrayer(String name) {
    switch (name) {
      case 'Imsak':
        return Icons.dark_mode_outlined;
      case 'Subuh':
        return Icons.nights_stay_rounded;
      case 'Terbit':
        return Icons.wb_sunny_outlined;
      case 'Dzuhur':
        return Icons.wb_sunny_rounded;
      case 'Ashar':
        return Icons.wb_twilight;
      case 'Maghrib':
        return Icons.nightlight_round;
      case 'Isya':
        return Icons.dark_mode_rounded;
      default:
        return Icons.access_time;
    }
  }

  Color _getColorForPrayer(String name) {
    switch (name) {
      case 'Imsak':
        return const Color(0xFF78909C);
      case 'Subuh':
        return const Color(0xFF42A5F5);
      case 'Terbit':
        return const Color(0xFFFFA726);
      case 'Dzuhur':
        return const Color(0xFFD4AF37);
      case 'Ashar':
        return const Color(0xFFFF7043);
      case 'Maghrib':
        return const Color(0xFFEF5350);
      case 'Isya':
        return const Color(0xFF7E57C2);
      default:
        return const Color(0xFF00BFA6);
    }
  }
}