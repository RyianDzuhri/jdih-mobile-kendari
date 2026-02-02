import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/produk_hukum_model.dart';
import '../../services/jdih_service.dart'; // Pastikan import service ini ada

class DetailPage extends StatefulWidget {
  final ProdukHukum produk; // Data awal dari List Page

  const DetailPage({super.key, required this.produk});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final JdihService _jdihService = JdihService();
  late Future<ProdukHukum> _detailFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API detail JDIHN saat halaman dibuka
    _detailFuture = _jdihService.getDetailProdukHukum(widget.produk.id);
  }

  // Fungsi helper untuk membuka link download
  Future<void> _launchDownload(String? url) async {
    if (url == null || url.isEmpty) return;
    
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka link download')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Detail Dokumen", 
          style: GoogleFonts.poppins(color: const Color(0xFF1a237e), fontWeight: FontWeight.bold, fontSize: 16)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Menggunakan FutureBuilder untuk menangani Loading data detail
      body: FutureBuilder<ProdukHukum>(
        future: _detailFuture,
        builder: (context, snapshot) {
          // 1. TAMPILAN LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. TENTUKAN DATA YANG DIPAKAI
          // Jika sukses ambil detail, pakai data API (snapshot.data).
          // Jika gagal, pakai data awal dari list (widget.produk) sebagai fallback.
          final dataTampil = snapshot.hasData ? snapshot.data! : widget.produk;
          final isError = snapshot.hasError;

          return _buildContent(dataTampil, isError: isError);
        },
      ),
    );
  }

  Widget _buildContent(ProdukHukum produk, {bool isError = false}) {
    final isBerlaku = produk.status.toLowerCase() == 'berlaku';
    final statusColor = isBerlaku ? Colors.green : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pesan Error jika gagal load detail
          if (isError)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Gagal memuat detail lengkap. Menampilkan data arsip.",
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),

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
                _buildDetailRow("Tahun", produk.tahunTerbit, Icons.calendar_today),
                const Divider(height: 24),
                
                // --- FIELD TAMBAHAN JDIHN ---
                if (produk.tanggalPengundangan != null && produk.tanggalPengundangan != "null") ...[
                   _buildDetailRow("Tgl Pengundangan", produk.tanggalPengundangan!, Icons.event_available),
                   const Divider(height: 24),
                ],
                if (produk.teuBadan != null && produk.teuBadan != "null") ...[
                   _buildDetailRow("TEU Badan", produk.teuBadan!, Icons.account_balance),
                   const Divider(height: 24),
                ],
                if (produk.penerbit != null && produk.penerbit != "null") ...[
                   _buildDetailRow("Penerbit", produk.penerbit!, Icons.domain), // Menggunakan icon domain
                   const Divider(height: 24),
                ],
                if (produk.sumber != null && produk.sumber != "null") ...[
                   _buildDetailRow("Sumber", produk.sumber!, Icons.source),
                   const Divider(height: 24),
                ],
                if (produk.lokasi != null && produk.lokasi != "null") ...[
                   _buildDetailRow("Lokasi Fisik", produk.lokasi!, Icons.location_on),
                   const Divider(height: 24),
                ],
                // -----------------------------

                _buildDetailRow("Bidang Hukum", produk.bidangHukum, Icons.gavel),
                const Divider(height: 24),
                _buildDetailRow("Bahasa", produk.bahasa ?? "Indonesia", Icons.language),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. ABSTRAK (Jika Ada)
          if (produk.abstrak != null && produk.abstrak!.isNotEmpty && produk.abstrak != "null") ...[
            Text("Abstrak", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                produk.abstrak!,
                style: GoogleFonts.lato(fontSize: 14, height: 1.5, color: Colors.grey[800]),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 25),
          ],

          // 4. FILE PDF VIEWER / DOWNLOAD
          if (produk.hasFile && produk.downloadUrl.isNotEmpty) ...[
             Text("Dokumen Lampiran", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
             const SizedBox(height: 10),
             
             // PDF Previewer
             SizedBox(
               height: 400,
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
                       const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 40),
                       const SizedBox(height: 10),
                       Text("Preview PDF tidak tersedia\nSilakan download manual", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.grey)),
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