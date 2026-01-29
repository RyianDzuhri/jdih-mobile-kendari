import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart'; 
import '../models/document_model.dart';
import '../services/api_service.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isDownloading = false;

  // --- LOGIKA DOWNLOAD ---
  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);

    try {
      // 1. Minta Link Download ke API (Hit Counter +1)
      final String? downloadUrl = await _apiService.getRealDownloadUrl(widget.document.id);

      if (downloadUrl == null || downloadUrl.isEmpty) {
        throw "Link file tidak ditemukan di database server.";
      }

      // 2. Tampilkan Snackbar Loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sedang mengunduh dokumen... Mohon tunggu.')),
        );
      }

      // 3. Download File sebagai Bytes (Mengirim API Key di Header)
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'X-API-Key': 'jdih_mobile_app_key', // Header keamanan
        },
      );

      if (response.statusCode == 200) {
        // 4. Simpan ke File Manager HP
        final directory = await getApplicationDocumentsDirectory();
        
        // Bersihkan nama file dari karakter aneh
        String safeFileName = "dokumen_${widget.document.id}.pdf";
        
        final file = File('${directory.path}/$safeFileName');
        await file.writeAsBytes(response.bodyBytes);

        print("File tersimpan: ${file.path}");

        // 5. Buka File PDF
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          throw "Berhasil download, tapi gagal membuka: ${result.message}";
        }

      } else if (response.statusCode == 404) {
        // ERROR HANDLING KHUSUS (Sesuai kondisi servermu saat ini)
        throw "Maaf, file fisik dokumen ini belum tersedia di server (Error 404).\nSilakan hubungi admin JDIH.";
      } else {
        throw "Gagal mengunduh. Server merespon: ${response.statusCode}";
      }

    } catch (e) {
      // Tampilkan Error Dialog yang Rapi
      if (mounted) _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Info Dokumen"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          )
        ],
      ),
    );
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    // Ambil warna status (Hijau jika berlaku, Merah jika tidak)
    final bool isBerlaku = widget.document.status.toLowerCase() == 'berlaku';
    final Color statusColor = isBerlaku ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Detail Dokumen", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Biru (Background Judul)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF1a237e),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Jenis Dokumen
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.document.jenisDokumen.toUpperCase(),
                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Judul Besar
                  Text(
                    widget.document.judul,
                    style: GoogleFonts.poppins(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      height: 1.5
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.document.status,
                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Card Detail Informasi
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailCard(
                    title: "Informasi Peraturan",
                    children: [
                      _buildInfoRow("Nomor", widget.document.nomorPeraturan),
                      _buildInfoRow("Tahun", widget.document.tahun),
                      _buildInfoRow("Bidang Hukum", widget.document.bidangHukum),
                      _buildInfoRow("Status", widget.document.status),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Card Abstrak
                  _buildDetailCard(
                    title: "Abstrak / Keterangan",
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          widget.document.abstrak ?? "Tidak ada abstrak untuk dokumen ini.",
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.lato(
                            fontSize: 14, 
                            color: Colors.grey[800], 
                            height: 1.6
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Tombol Download Melayang di Bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isDownloading ? null : _handleDownload,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1a237e), // Warna Biru JDIH
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: _isDownloading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.download_rounded, color: Colors.white),
          label: Text(
            _isDownloading ? "Sedang Mengunduh..." : "Unduh Dokumen Lengkap",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Putih
  Widget _buildDetailCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 24, width: 4,
                decoration: BoxDecoration(color: const Color(0xFF1a237e), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  // Widget Helper untuk Baris Data
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value, 
              style: GoogleFonts.lato(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}