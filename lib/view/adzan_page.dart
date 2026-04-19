import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodel/shalat_view_model.dart';
import '../utils/adzan_service.dart';

class AdzanPage extends StatefulWidget {
  const AdzanPage({super.key});

  @override
  State<AdzanPage> createState() => _AdzanPageState();
}

class _AdzanPageState extends State<AdzanPage> {
  final AdzanService _adzanService = AdzanService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = context.read<ShalatViewModel>();
      if (vm.todayPrayer == null) {
        vm.fetchTodayPrayer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShalatViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('Adzan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B3A4B), Color(0xFF152238)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFFD4AF37),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Adzan Otomatis',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Adzan akan diputar otomatis saat waktu shalat tiba',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00BFA6).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _adzanService.getCountdown(),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00BFA6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Muadzin selection
                  Text(
                    'Pilih Muadzin',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...AdzanService.adzanUrls.keys.map(
                    (muadzin) => _muadzinCard(muadzin),
                  ),

                  const SizedBox(height: 24),

                  /// Waktu shalat list with play buttons
                  Text(
                    'Putar Adzan Manual',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (vm.todayPrayer != null)
                    ...vm.todayPrayer!.wajibPrayers.map(
                      (entry) => _prayerAdzanCard(entry.key, entry.value),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _muadzinCard(String name) {
    final isSelected = _adzanService.selectedMuadzin == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _adzanService.selectedMuadzin = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withOpacity(0.1)
              : const Color(0xFF152238),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37).withOpacity(0.4)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4AF37).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : Colors.white38,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Muadzin $name',
              style: GoogleFonts.poppins(
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white70,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD4AF37),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _prayerAdzanCard(String name, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF152238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (_adzanService.isPlaying) {
                await _adzanService.stop();
              } else {
                await _adzanService.playAdzan();
              }
              setState(() {});
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFF5D77A)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _adzanService.isPlaying
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                color: const Color(0xFF0D1B2A),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
