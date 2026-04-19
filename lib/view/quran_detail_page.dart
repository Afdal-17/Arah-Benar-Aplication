import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../viewmodel/quran_view_model.dart';

class QuranDetailPage extends StatefulWidget {
  final int? nomorSurat;
  final int? nomorJuz;
  final String namaSurat;
  final String namaArab;
  final String? audioFullUrl;

  const QuranDetailPage({
    super.key,
    this.nomorSurat,
    this.nomorJuz,
    required this.namaSurat,
    required this.namaArab,
    this.audioFullUrl,
  });

  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}

class _QuranDetailPageState extends State<QuranDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingAyat;
  bool _isPlayingAll = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = context.read<QuranViewModel>();
      if (widget.nomorSurat != null) {
        vm.fetchSurat(widget.nomorSurat!);
      } else if (widget.nomorJuz != null) {
        vm.fetchJuz(widget.nomorJuz!);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAyat(int ayatNumber, String? url) async {
    if (url == null) return;

    try {
      if (_playingAyat == ayatNumber && _audioPlayer.playing) {
        await _audioPlayer.stop();
        setState(() => _playingAyat = null);
        return;
      }

      setState(() => _playingAyat = ayatNumber);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _playingAyat = null);
        }
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) setState(() => _playingAyat = null);
    }
  }

  Future<void> _playAllAyat() async {
    final vm = context.read<QuranViewModel>();
    if (_isPlayingAll) {
      await _audioPlayer.stop();
      setState(() {
        _isPlayingAll = false;
        _playingAyat = null;
      });
      return;
    }

    setState(() => _isPlayingAll = true);

    for (final ayat in vm.ayat) {
      if (!_isPlayingAll || !mounted) break;

      final url = ayat.audioUrl;
      if (url == null) continue;

      setState(() => _playingAyat = ayat.nomorAyat);

      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();

        // Wait for completion
        await _audioPlayer.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );
      } catch (e) {
        debugPrint('Error auto-play: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isPlayingAll = false;
        _playingAyat = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuranViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.namaSurat,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            Text(widget.namaArab,
                style: GoogleFonts.amiri(
                    fontSize: 14, color: const Color(0xFFD4AF37))),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          /// Play All button
          IconButton(
            onPressed: _playAllAyat,
            icon: Icon(
              _isPlayingAll
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_rounded,
              color: const Color(0xFFD4AF37),
              size: 30,
            ),
            tooltip: _isPlayingAll ? 'Stop' : 'Putar Semua',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : vm.error != null
              ? Center(
                  child: Text(
                    'Error: ${vm.error}',
                    style: GoogleFonts.poppins(color: Colors.redAccent),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: vm.ayat.length + 1, // +1 for Bismillah header
                  itemBuilder: (_, i) {
                    /// Header with Bismillah
                    if (i == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(vertical: 24),
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
                            Text(
                              widget.namaArab,
                              style: GoogleFonts.amiri(
                                color: const Color(0xFFD4AF37),
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.namaSurat,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vm.ayat.length} Ayat',
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(
                              color: Color(0xFFD4AF37),
                              indent: 50,
                              endIndent: 50,
                              thickness: 0.5,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                              style: GoogleFonts.amiri(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final ayat = vm.ayat[i - 1];
                    final isPlaying = _playingAyat == ayat.nomorAyat;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? const Color(0xFFD4AF37).withOpacity(0.08)
                            : const Color(0xFF152238),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPlaying
                              ? const Color(0xFFD4AF37).withOpacity(0.3)
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          /// Ayat number bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B2A).withOpacity(0.5),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${ayat.nomorAyat}',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFD4AF37),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Play button
                                if (ayat.audioUrl != null)
                                  GestureDetector(
                                    onTap: () => _playAyat(
                                        ayat.nomorAyat, ayat.audioUrl),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? const Color(0xFFD4AF37)
                                            : const Color(0xFF00BFA6)
                                                .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isPlaying
                                            ? Icons.stop_rounded
                                            : Icons.play_arrow_rounded,
                                        color: isPlaying
                                            ? const Color(0xFF0D1B2A)
                                            : const Color(0xFF00BFA6),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          /// Content
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                /// Arabic text
                                Text(
                                  ayat.arab,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.amiri(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                /// Latin transliteration
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    ayat.latin,
                                    style: GoogleFonts.poppins(
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF00BFA6),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                /// Indonesian translation
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    ayat.arti,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 13,
                                      height: 1.6,
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
}
