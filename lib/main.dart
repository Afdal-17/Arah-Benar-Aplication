import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

import 'repository/quran_repository.dart';
import 'repository/doa_repository.dart';
import 'repository/prayer_time_repository.dart';

import 'viewmodel/shalat_view_model.dart';
import 'viewmodel/quran_view_model.dart';
import 'viewmodel/doa_view_model.dart';

import 'view/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ArahBenarApp());
}

class ArahBenarApp extends StatelessWidget {
  const ArahBenarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => PrayerTimeRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              ShalatViewModel(context.read<PrayerTimeRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => QuranViewModel(QuranRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => DoaViewModel(DoaRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Arah Benar',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1B2A),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF00BFA6),
            secondary: const Color(0xFFD4AF37),
            surface: const Color(0xFF1B2838),
            onSurface: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF0D1B2A),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1B2838),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}