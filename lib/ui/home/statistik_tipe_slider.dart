import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/statistic_model.dart';

class StatistikTipeSlider extends StatelessWidget {
  final List<StatistikItem> dataTipe;

  const StatistikTipeSlider({super.key, required this.dataTipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            "Kategori Dokumen",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e)),
          ),
        ),
        const SizedBox(height: 15),

        // --- BAGIAN YANG DIUBAH ---
        SizedBox(
          height: 140, // <--- UBAH JADI 140 (Sebelumnya 110)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dataTipe.length,
            itemBuilder: (context, index) {
              final item = dataTipe[index];
              return Container(
                width: 140, 
                margin: const EdgeInsets.only(right: 12, bottom: 10), // Tambah bottom margin dikit buat bayangan
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.folder_open_rounded, size: 20, color: Color(0xFF1a237e)),
                    ),
                    const Spacer(),
                    Text(
                      "${item.total}",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e)),
                    ),
                    const SizedBox(height: 4), // Jarak sedikit dilonggarkan
                    Text(
                      item.label, 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}