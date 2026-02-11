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

  // WARNA TEMA
  final Color _primaryDark = const Color(0xFF111827);
  final Color _accentOrange = const Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    _detailFuture = _jdihService.getDetailLengkap(widget.produk.id);
  }

  Future<void> _launchDownload(String? url, String labelFile) async {
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Maaf, Link File $labelFile tidak valid')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), 
      appBar: AppBar(
        title: Text("Detail Dokumen", style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: FutureBuilder<ProdukHukum>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryDark));
          }
          final dataTampil = snapshot.hasData ? snapshot.data! : widget.produk;
          final isError = snapshot.hasError;

          return _buildContent(dataTampil, isError: isError);
        },
      ),
    );
  }

  Widget _buildContent(ProdukHukum produk, {bool isError = false}) {
    final isBerlaku = produk.status.toLowerCase().contains('berlaku');
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
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Gagal memuat detail lengkap.", style: GoogleFonts.lato(color: Colors.red.shade900))),
                ],
              ),
            ),

          // HEADER & METADATA
          _buildHeaderSection(produk, isBerlaku, statusColor),
          const SizedBox(height: 20),
          _buildMetadataSection(produk),
          const SizedBox(height: 25),

          // --- BAGIAN ABSTRAK (MODIFIKASI) ---
          // Kita hanya tampilkan tombol download jika URL Abstrak ada.
          // Teks nama file 'htfi...pdf' TIDAK AKAN DITAMPILKAN LAGI.
          if (produk.abstrakUrl != null && produk.abstrakUrl!.isNotEmpty) ...[
             Row(
               children: [
                 Icon(Icons.library_books_rounded, color: _primaryDark),
                 const SizedBox(width: 10),
                 Text("Abstrak / Ringkasan", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryDark)),
               ],
             ),
             const SizedBox(height: 15),

             // TOMBOL DOWNLOAD ABSTRAK
             Container(
               margin: const EdgeInsets.only(bottom: 25),
               width: double.infinity,
               height: 50,
               child: OutlinedButton.icon(
                 style: OutlinedButton.styleFrom(
                   foregroundColor: _primaryDark,
                   backgroundColor: Colors.white,
                   side: BorderSide(color: _primaryDark),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   elevation: 0,
                 ),
                 onPressed: () => _launchDownload(produk.abstrakUrl, "Abstrak"), 
                 icon: const Icon(Icons.description_outlined),
                 label: Text("Download File Abstrak", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
               ),
             ),
          ],

          // --- BAGIAN DOKUMEN LAMPIRAN UTAMA ---
          if (produk.hasFile && produk.downloadUrl.isNotEmpty) ...[
             Row(
               children: [
                 Icon(Icons.picture_as_pdf_rounded, color: _primaryDark),
                 const SizedBox(width: 10),
                 Text("Dokumen Lampiran", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryDark)),
               ],
             ),
             const SizedBox(height: 15),
             
             Listener(
               onPointerDown: (_) => setState(() => _pageScrollPhysics = const NeverScrollableScrollPhysics()),
               onPointerUp: (_) => setState(() => _pageScrollPhysics = const AlwaysScrollableScrollPhysics()),
               onPointerCancel: (_) => setState(() => _pageScrollPhysics = const AlwaysScrollableScrollPhysics()),
               child: Container(
                 height: 500,
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.grey.shade300),
                   borderRadius: BorderRadius.circular(16),
                   color: Colors.grey.shade100,
                 ),
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(15),
                   child: const PDF(
                     enableSwipe: true,
                     swipeHorizontal: false, 
                     autoSpacing: true,
                     pageFling: true,
                     pageSnap: false,
                     fitEachPage: false,
                   ).cachedFromUrl(
                     produk.downloadUrl,
                     placeholder: (progress) => Center(child: Text('$progress %', style: GoogleFonts.lato())),
                     errorWidget: (error) => Center(child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                         const SizedBox(height: 10),
                         Text("Preview tidak tersedia", style: GoogleFonts.lato(color: Colors.grey)),
                       ],
                     )),
                   ),
                 ),
               ),
             ),
             
             const SizedBox(height: 20),

             // TOMBOL DOWNLOAD UTAMA
             SizedBox(
               width: double.infinity,
               height: 55,
               child: ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: _primaryDark,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   elevation: 4,
                   shadowColor: _primaryDark.withOpacity(0.4),
                 ),
                 onPressed: () => _launchDownload(produk.downloadUrl, "PDF Lengkap"),
                 icon: const Icon(Icons.download_rounded, color: Colors.white),
                 label: Text("Download PDF Lengkap", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
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
           
           const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Widget Helper ---
  Widget _buildHeaderSection(ProdukHukum produk, bool isBerlaku, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text(
              produk.jenis, 
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w800, color: _primaryDark)
            ),
          ),
          const SizedBox(height: 15),
          Text(
            produk.judul, 
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, height: 1.6, color: Colors.black87)
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(isBerlaku ? Icons.check_circle : Icons.cancel, color: statusColor, size: 20), 
                const SizedBox(width: 8), 
                Text(produk.status, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: statusColor))
              ]),
              if (produk.dilihat != null) 
                Row(children: [
                  Icon(Icons.remove_red_eye_rounded, size: 16, color: Colors.grey[400]), 
                  const SizedBox(width: 4), 
                  Text("${produk.dilihat}", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])), 
                  const SizedBox(width: 12), 
                  Icon(Icons.download_rounded, size: 16, color: Colors.grey[400]), 
                  const SizedBox(width: 4), 
                  Text("${produk.diunduh}", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]))
                ])
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(ProdukHukum produk) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(children: [
        _buildDetailRow("Nomor Peraturan", produk.nomorPeraturan, Icons.tag_rounded),
        const Divider(height: 30),
        _buildDetailRow("Tahun Terbit", produk.tahunTerbit, Icons.calendar_today_rounded),
        const Divider(height: 30),
        if (produk.tanggalPenetapan != null) ...[_buildDetailRow("Tgl Penetapan", produk.tanggalPenetapan!, Icons.edit_calendar_rounded), const Divider(height: 30)],
        if (produk.penandatanganan != null) ...[_buildDetailRow("Penandatangan", produk.penandatanganan!, Icons.draw_rounded), const Divider(height: 30)],
        if (produk.teuBadan != null) ...[_buildDetailRow("TEU Badan", produk.teuBadan!, Icons.account_balance_rounded), const Divider(height: 30)],
        _buildDetailRow("Bidang Hukum", produk.bidangHukum, Icons.gavel_rounded),
      ]),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Container(
          padding: const EdgeInsets.all(10), 
          decoration: BoxDecoration(color: _accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), 
          child: Icon(icon, size: 20, color: _accentOrange)
        ), 
        const SizedBox(width: 16), 
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold)), 
              const SizedBox(height: 4), 
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: _primaryDark))
            ]
          )
        )
      ]
    );
  }
}