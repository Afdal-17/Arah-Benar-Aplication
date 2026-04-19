import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/quran_view_model.dart';
import '../model/quran_surah_model.dart';
import 'quran_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<QuranViewModel>().fetchAllSurah());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuranViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text("Al-Qur'an",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          indicatorWeight: 3,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Surah'),
            Tab(text: 'Juz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// TAB 1: Surah List
          _buildSurahTab(vm),

          /// TAB 2: Juz Grid
          _buildJuzTab(),
        ],
      ),
    );
  }

  Widget _buildSurahTab(QuranViewModel vm) {
    if (vm.isLoading && vm.surahList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    if (vm.error != null && vm.surahList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => vm.fetchAllSurah(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
          ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final filtered = vm.surahList.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.namaLatin.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.arti.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.nomor.toString() == _searchQuery;
    }).toList();

    return Column(
      children: [
        /// Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF152238),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari surah...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        /// Surah List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _surahCard(filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _surahCard(QuranSurah surah) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranDetailPage(
              nomorSurat: surah.nomor,
              namaSurat: surah.namaLatin,
              namaArab: surah.nama,
              audioFullUrl: surah.audioFull.isNotEmpty
                  ? surah.audioFull.values.first
                  : null,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF152238),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            /// Number badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.2),
                    const Color(0xFFD4AF37).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${surah.nomor}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// Latin name & info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.namaLatin,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.tempatTurun} • ${surah.jumlahAyat} Ayat • ${surah.arti}',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            /// Arabic name
            Text(
              surah.nama,
              style: GoogleFonts.amiri(
                color: const Color(0xFF00BFA6),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 30,
      itemBuilder: (_, i) {
        final juzNumber = i + 1;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranDetailPage(
                  nomorJuz: juzNumber,
                  namaSurat: 'Juz $juzNumber',
                  namaArab: 'الجزء $juzNumber',
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1B3A4B),
                  const Color(0xFF152238),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                '$juzNumber',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}