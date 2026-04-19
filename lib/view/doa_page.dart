import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/doa_view_model.dart';

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DoaViewModel>().fetchDoa());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoaViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text("Doa-Doa",
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
                      Text('Gagal memuat doa',
                          style: GoogleFonts.poppins(color: Colors.white60)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => vm.fetchDoa(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37)),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: vm.doaList.length,
                  itemBuilder: (_, i) {
                    final doa = vm.doaList[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152238),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 6),
                          childrenPadding: const EdgeInsets.fromLTRB(
                              18, 0, 18, 18),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFAB47BC).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFAB47BC),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            doa.judul,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          iconColor: const Color(0xFFD4AF37),
                          collapsedIconColor: Colors.white38,
                          children: [
                            /// Arabic
                            Text(
                              doa.arab,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.amiri(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 2,
                              ),
                            ),
                            const SizedBox(height: 14),

                            /// Latin
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                doa.latin,
                                style: GoogleFonts.poppins(
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF00BFA6),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// Arti
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                doa.arti,
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}