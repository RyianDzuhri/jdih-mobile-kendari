import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/produk_hukum_model.dart';
import '../produk_hukum/detail_page.dart';

class ProdukCard extends StatelessWidget {
  final ProdukHukum produk;

  const ProdukCard({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema Lokal agar konsisten
    const Color primaryDark = Color(0xFF111827);
    const Color accentOrange = Color(0xFFF97316);

    // Cek Status
    final bool isBerlaku = produk.status.toLowerCase().contains("berlaku");
    final Color statusColor = isBerlaku ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Shadow lebih halus dan modern
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(produk: produk)));
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER: Tag Jenis & Ikon Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip Jenis Dokumen
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6), // Abu-abu sangat muda (Theme Web)
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        produk.jenis, 
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w800, // Lebih tebal
                          color: primaryDark, // Biru Gelap
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Ikon Status (Checklist/Silang)
                    Icon(
                      isBerlaku ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 22,
                      color: statusColor,
                    ),
                  ],
                ),
                
                const SizedBox(height: 14),
                
                // 2. JUDUL
                Text(
                  produk.judul,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // Garis Pembatas Putus-putus (Opsional) atau Solid Tipis
                Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
                
                const SizedBox(height: 12),

                // 3. FOOTER: Tahun & Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Kiri Kanan Mentok
                  crossAxisAlignment: CrossAxisAlignment.center,     // Vertikal Tengah
                  children: [
                    // Kiri: Tahun
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          "Tahun ${produk.tahunTerbit}",
                          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    // Kanan: Tombol Lihat Detail (Oranye)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentOrange.withOpacity(0.08), // Background oranye pudar
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Lihat Detail",
                            style: GoogleFonts.lato(
                              fontSize: 11, 
                              color: accentOrange, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: accentOrange),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}