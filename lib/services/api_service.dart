import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class ApiService {
  // Ganti IP sesuai kondisimu
  static const String baseUrl = 'http://jdih.kendarikota.go.id/api';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-API-Key': 'jdih_mobile_app_key', 
  };

  // 1. Ambil Dokumen dengan Pagination & Filter Server-Side
  Future<List<DocumentModel>> getDocuments({
    int page = 1, 
    int limit = 10, 
    String search = '',
    String category = ''
  }) async {
    try {
      // Menyusun Query Parameters
      // Hasil URL: .../all-documents?page=1&limit=10&search=hukum&kategori=PERDA
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
        'kategori': category,
      };

      final uri = Uri.parse('$baseUrl/jdih/all-documents').replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Sesuaikan dengan struktur JSON backend Anda.
        // Jika backend Laravel default pagination, biasanya ada di ['data']['data']
        // Jika custom, sesuaikan kuncinya. Di sini saya pakai asumsi ['data'] adalah List.
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        return data.map((e) => DocumentModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // 2. Logic Download (Tidak berubah)
  Future<String?> getRealDownloadUrl(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jdih/documents/$id/download'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['file_info'] != null) {
          return data['file_info']['download_url'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // 3. AMBIL JENIS DOKUMEN (Tidak berubah)
  Future<List<String>> getDocumentTypes() async {
    final url = Uri.parse('$baseUrl/jdih/document-types'); 
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item['nama'].toString()).toList();
      }
      return [];
    } catch (e) {
      return ['PERATURAN DAERAH', 'PERATURAN WALIKOTA', 'KEPUTUSAN WALIKOTA'];
    }
  }
}