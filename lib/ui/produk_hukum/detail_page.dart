import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/produk_hukum_model.dart';
import '../../services/jdih_service.dart';

class DetailPage extends StatefulWidget {
  final ProdukHukum produk;

  const DetailPage({super.key, required this.produk});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final JdihService _jdihService = JdihService();
  late Future<ProdukHukum> _detailFuture;
  ScrollPhysics _pageScrollPhysics = const AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    // Panggil Service Gabungan
    _detailFuture = _jdihService.getDetailLengkap(widget.produk.id);
  }

  Future<void> _launchDownload(String? url) async {
    print("TOMBOL DITEKAN. URL: '$url'"); // <-- CEK LOG INI

    if (url == null || url.isEmpty || url == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maaf, File PDF tidak ditemukan di server')));
      return;
    }
    
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka browser')));
        }
      }
    } catch (e) {
      print("Error Launch URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<ProdukHukum>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
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
      physics: _pageScrollPhysics,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isError)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(child: Text("Gagal memuat detail lengkap.")),
                ],
              ),
            ),

          // Header & Metadata (Kode Sama seperti sebelumnya...)
          _buildHeaderSection(produk, isBerlaku, statusColor),
          const SizedBox(height: 20),
          _buildMetadataSection(produk),
          const SizedBox(height: 25),

          if (produk.abstrak != null && produk.abstrak!.isNotEmpty)
             _buildAbstrakSection(produk.abstrak!),

          // PDF VIEW & DOWNLOAD
          if (produk.hasFile && produk.downloadUrl.isNotEmpty) ...[
             Text("Dokumen Lampiran", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
             const SizedBox(height: 10),
             
             // PDF PREVIEW
             Listener(
               onPointerDown: (_) => setState(() => _pageScrollPhysics = const NeverScrollableScrollPhysics()),
               onPointerUp: (_) => setState(() => _pageScrollPhysics = const AlwaysScrollableScrollPhysics()),
               onPointerCancel: (_) => setState(() => _pageScrollPhysics = const AlwaysScrollableScrollPhysics()),
               child: SizedBox(
                 height: 500,
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(16),
                   child: const PDF(
                     enableSwipe: true,
                     swipeHorizontal: false,
                     autoSpacing: true,
                     pageFling: true,
                     pageSnap: false,
                     fitEachPage: false,
                   ).cachedFromUrl(
                     produk.downloadUrl, // <--- Ini URL yang sudah diperbaiki Model
                     placeholder: (progress) => Center(child: Text('$progress %', style: GoogleFonts.lato())),
                     errorWidget: (error) => Center(child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                         const SizedBox(height: 10),
                         // Tampilkan URL agar kita bisa debug kalau masih salah
                         Text("URL Error: ${produk.downloadUrl}", textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.red, fontSize: 10)),
                       ],
                     )),
                   ),
                 ),
               ),
             ),
             
             const SizedBox(height: 20),

             // TOMBOL DOWNLOAD
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
                   Expanded(child: Text("Dokumen digital tidak tersedia.", style: GoogleFonts.lato(color: Colors.orange.shade900))),
                 ],
               ),
             ),
           
           const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Widget Helper (Sama seperti sebelumnya) ---
  Widget _buildHeaderSection(ProdukHukum produk, bool isBerlaku, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
            child: Text(produk.jenis.toUpperCase(), style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
          ),
          const SizedBox(height: 15),
          Text(produk.judul, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: Colors.black87)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(isBerlaku ? Icons.check_circle : Icons.cancel, color: statusColor, size: 20), const SizedBox(width: 8), Text("Status: ${produk.status}", style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: statusColor))]),
              if (produk.dilihat != null) Row(children: [const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey), const SizedBox(width: 4), Text("${produk.dilihat}", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)), const SizedBox(width: 10), const Icon(Icons.download, size: 16, color: Colors.grey), const SizedBox(width: 4), Text("${produk.diunduh}", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey))])
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(ProdukHukum produk) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(children: [
        _buildDetailRow("Nomor", produk.nomorPeraturan, Icons.tag),
        const Divider(height: 24),
        _buildDetailRow("Tahun", produk.tahunTerbit, Icons.calendar_today),
        const Divider(height: 24),
        if (produk.tanggalPenetapan != null) ...[_buildDetailRow("Tgl Penetapan", produk.tanggalPenetapan!, Icons.edit_calendar), const Divider(height: 24)],
        if (produk.penandatanganan != null) ...[_buildDetailRow("Penandatangan", produk.penandatanganan!, Icons.draw), const Divider(height: 24)],
        if (produk.teuBadan != null) ...[_buildDetailRow("TEU Badan", produk.teuBadan!, Icons.account_balance), const Divider(height: 24)],
        _buildDetailRow("Bidang Hukum", produk.bidangHukum, Icons.gavel),
      ]),
    );
  }

  Widget _buildAbstrakSection(String abstrak) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Abstrak", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
      const SizedBox(height: 10),
      Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(abstrak, style: GoogleFonts.lato(fontSize: 14, height: 1.5, color: Colors.grey[800]), textAlign: TextAlign.justify)),
      const SizedBox(height: 25),
    ]);
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: const Color(0xFF1a237e))), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])), const SizedBox(height: 4), Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87))]))]);
  }
}