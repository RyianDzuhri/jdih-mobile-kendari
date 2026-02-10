import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/statistic_model.dart';

class StatistikTipeSlider extends StatelessWidget {
  final List<StatistikItem> dataTipe;

  const StatistikTipeSlider({super.key, required this.dataTipe});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    const Color primaryDark = Color(0xFF111827);
    const Color accentOrange = Color(0xFFF97316);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            "Kategori Dokumen",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: primaryDark),
          ),
        ),
        const SizedBox(height: 15),

        SizedBox(
          height: 140, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dataTipe.length,
            itemBuilder: (context, index) {
              final item = dataTipe[index];
              return Container(
                width: 140, 
                margin: const EdgeInsets.only(right: 12, bottom: 10), // Margin bawah untuk shadow
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentOrange.withOpacity(0.1), // Background Oranye Muda
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder_open_rounded, size: 22, color: accentOrange), // Icon Oranye
                    ),
                    
                    const Spacer(),
                    
                    // Angka Total
                    Text(
                      "${item.total}",
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDark),
                    ),
                    const SizedBox(height: 2), 
                    
                    // Label Kategori
                    Text(
                      item.label, 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
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