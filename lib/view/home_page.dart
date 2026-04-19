import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';

import '../viewmodel/shalat_view_model.dart';
import '../utils/adzan_service.dart';

import '../view/shalat_page.dart';
import '../view/quran_page.dart';
import '../view/doa_page.dart';
import '../pages/kiblat_page.dart';
import '../view/tasbih_page.dart';
import '../view/kalender_page.dart';
import '../view/hadits_page.dart';
import '../view/masjid_page.dart';
import '../view/adzan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String lokasi = "Mengambil lokasi...";
  String waktu = "--:--";
  String greeting = "Assalamu'alaikum";
  String tanggalHijri = "";
  String nextPrayerInfo = "";
  Timer? _clockTimer;
  final AdzanService _adzanService = AdzanService();

  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();

    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerAnimController.forward();

    _updateTime();
    _getLocation();
    _setupHijriDate();
    _fetchPrayerAndSetupAdzan();

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateTime();
      _updateNextPrayer();
    });

    _adzanService.onAdzanTriggered = () {
      if (mounted) {
        _showAdzanDialog();
      }
    };
  }

  void _setupHijriDate() {
    final hijri = HijriCalendar.now();
    setState(() {
      tanggalHijri = "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H";
    });
  }

  Future<void> _fetchPrayerAndSetupAdzan() async {
    final vm = context.read<ShalatViewModel>();
    await vm.fetchTodayPrayer();
    if (vm.todayPrayer != null) {
      _adzanService.setPrayerTimes(vm.todayPrayer!);
      _updateNextPrayer();
    }
  }

  void _updateNextPrayer() {
    setState(() {
      nextPrayerInfo = _adzanService.getCountdown();
    });
  }

  void _showAdzanDialog() {
    final next = _adzanService.getNextPrayer();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 28),
            const SizedBox(width: 10),
            Text(
              'Waktu Shalat Tiba',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Saatnya menunaikan shalat ${next?.key ?? ''}',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _adzanService.stop();
              Navigator.pop(ctx);
            },
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF00BFA6))),
          ),
        ],
      ),
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour;

    setState(() {
      waktu =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      if (hour >= 3 && hour < 11) {
        greeting = "Selamat Pagi 🌅";
      } else if (hour < 15) {
        greeting = "Selamat Siang ☀️";
      } else if (hour < 18) {
        greeting = "Selamat Sore 🌤️";
      } else {
        greeting = "Selamat Malam 🌙";
      }
    });
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => lokasi = "GPS tidak aktif");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => lokasi = "Izin lokasi ditolak");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (kIsWeb) {
        setState(() {
          lokasi =
              "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        });
        return;
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      setState(() {
        lokasi =
            "${place.locality ?? place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}";
      });
    } catch (e) {
      setState(() {
        lokasi = "Gagal mengambil lokasi";
      });
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /// ================= HEADER =================
            FadeTransition(
              opacity: _headerFadeAnim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 55, 24, 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B3A4B), Color(0xFF0D2137)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.mosque_rounded,
                                color: Color(0xFFD4AF37),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Arah Benar",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00BFA6).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tanggalHijri,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00BFA6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// GREETING
                    Text(
                      greeting,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD4AF37).withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// WAKTU
                    Text(
                      waktu,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// LOKASI
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: const Color(0xFF00BFA6).withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lokasi,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// NEXT PRAYER COUNTDOWN
                    if (nextPrayerInfo.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD4AF37).withOpacity(0.15),
                              const Color(0xFFD4AF37).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_rounded,
                              color: Color(0xFFD4AF37),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              nextPrayerInfo,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFD4AF37),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= MENU TITLE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Menu Utama",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// ================= MENU GRID =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF152238),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.78,
                children: [
                  _menuItem(context, Icons.menu_book_rounded,
                      "Al-Qur'an", const Color(0xFF00BFA6), const QuranPage()),
                  _menuItem(context, Icons.access_time_rounded,
                      "Shalat", const Color(0xFF42A5F5), const ShalatPage()),
                  _menuItem(context, Icons.explore_rounded,
                      "Kiblat", const Color(0xFFD4AF37), const KiblatPage()),
                  _menuItem(context, Icons.volume_up_rounded,
                      "Adzan", const Color(0xFFEF5350), const AdzanPage()),
                  _menuItem(context, Icons.favorite_rounded,
                      "Doa", const Color(0xFFAB47BC), const DoaPage()),
                  _menuItem(context, Icons.chrome_reader_mode_rounded,
                      "Hadits", const Color(0xFF26C6DA), const HaditsPage()),
                  _menuItem(context, Icons.calendar_month_rounded,
                      "Kalender", const Color(0xFFFFA726), const KalenderPage()),
                  _menuItem(context, Icons.touch_app_rounded,
                      "Tasbih", const Color(0xFF66BB6A), const TasbihPage()),
                  _menuItem(context, Icons.mosque_rounded,
                      "Masjid", const Color(0xFF78909C), const MasjidPage()),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => page,
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}