import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart'; // Jangan lupa tambahkan url_launcher di pubspec.yaml jika mau tombol download eksternal
import '../../models/produk_hukum_model.dart';

class DetailPage extends StatelessWidget {
  final ProdukHukum produk;

  const DetailPage({super.key, required this.produk});

  // Fungsi helper untuk membuka link di browser luar
  Future<void> _launchDownload(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna status
    final isBerlaku = produk.status.toLowerCase() == 'berlaku';
    final statusColor = isBerlaku ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Detail Dokumen", style: GoogleFonts.poppins(color: const Color(0xFF1a237e), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER KARTU (JUDUL & JENIS)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Jenis
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      produk.jenis.toUpperCase(),
                      style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Judul Besar
                  Text(
                    produk.judul,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Info Status
                  Row(
                    children: [
                      Icon(isBerlaku ? Icons.check_circle : Icons.cancel, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Status: ${produk.status}",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. DETAIL METADATA (GRID)
            Text("Informasi Detail", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildDetailRow("Nomor Peraturan", produk.nomorPeraturan, Icons.tag),
                  const Divider(height: 24),
                  _buildDetailRow("Tahun Terbit", produk.tahunTerbit, Icons.calendar_today),
                  const Divider(height: 24),
                  _buildDetailRow("Bidang Hukum", produk.bidangHukum, Icons.gavel), // <--- DATA BARU
                  const Divider(height: 24),
                  _buildDetailRow("Jenis Dokumen", produk.jenis, Icons.category),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. FILE PDF VIEWER / DOWNLOAD
            if (produk.hasFile) ...[
               Text("Dokumen Lampiran", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
               const SizedBox(height: 10),
               
               // Tombol Buka PDF (In App)
               SizedBox(
                 height: 400, // Tinggi area PDF
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(16),
                   child: const PDF(
                     enableSwipe: true,
                     swipeHorizontal: false,
                     autoSpacing: false,
                     pageFling: false,
                   ).cachedFromUrl(
                     produk.downloadUrl,
                     placeholder: (progress) => Center(child: Text('$progress %', style: GoogleFonts.lato())),
                     errorWidget: (error) => Center(child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.error_outline, color: Colors.red, size: 40),
                         const SizedBox(height: 10),
                         Text("Gagal memuat PDF preview\nSilakan download manual", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.grey)),
                       ],
                     )),
                   ),
                 ),
               ),
               
               const SizedBox(height: 20),

               // Tombol Download Manual
               SizedBox(
                 width: double.infinity,
                 height: 55,
                 child: ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF1a237e),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     elevation: 2,
                   ),
                   onPressed: () => _launchDownload(produk.downloadUrl),
                   icon: const Icon(Icons.download_rounded, color: Colors.white),
                   label: Text("Download PDF Lengkap", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                 ),
               ),
            ] else 
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
                 child: Row(
                   children: [
                     Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                     const SizedBox(width: 10),
                     Expanded(child: Text("Dokumen digital belum tersedia untuk peraturan ini.", style: GoogleFonts.lato(color: Colors.orange.shade900))),
                   ],
                 ),
               ),
             
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Baris Detail
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: const Color(0xFF1a237e)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}