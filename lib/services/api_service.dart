import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';


class ApiService {
  // Ganti IP sesuai kondisimu (Emulator: 10.0.2.2, HP Fisik: IP Laptop)
  static const String baseUrl = 'http://jdih.kendarikota.go.id/api';

  // Header Wajib (Sesuai logic backend: harus berawalan 'jdih_')
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-API-Key': 'jdih_mobile_app_key', 
  };

  // 1. Ambil Semua Dokumen
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jdih/all-documents'),
        headers: headers, // <--- PENTING
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Backend mengembalikan: { total: ..., data: [...] }
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => DocumentModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // 2. Logic Download (Hit API dulu untuk counter, baru dapat Link)
  Future<String?> getRealDownloadUrl(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jdih/documents/$id/download'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend return: { ..., file_info: { download_url: "..." } }
        if (data['file_info'] != null) {
          return data['file_info']['download_url'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // 3. AMBIL JENIS DOKUMEN (Untuk Filter Chips)
  Future<List<String>> getDocumentTypes() async {
    // Pastikan URL ini mengarah ke route yang kamu buat di atas
    final url = Uri.parse('$baseUrl/jdih/document-types'); 
    
    try {
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        // Respon server kamu berupa List of Objects:
        // [ {"id":1, "nama":"PERATURAN DAERAH", ...}, ... ]
        final List<dynamic> data = json.decode(response.body);
        
        // Kita ambil value dari key 'nama' saja untuk dijadikan List<String>
        return data.map((item) => item['nama'].toString()).toList();
      }
      return [];
    } catch (e) {
      print("Gagal ambil tipe dokumen: $e");
      // Fallback manual jika server error
      return ['PERATURAN DAERAH', 'PERATURAN WALIKOTA', 'KEPUTUSAN WALIKOTA'];
    }
  }
}