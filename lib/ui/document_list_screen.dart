import 'dart:async'; // Tambahan untuk Timer debounce search
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/document_model.dart';
import 'document_detail_screen.dart';

class DocumentListScreen extends StatefulWidget {
  final String? categoryFilter; // Filter dari Menu Home (Misal: PRODUK_HUKUM)
  final String pageTitle;

  const DocumentListScreen({
    super.key, 
    this.categoryFilter, 
    this.pageTitle = 'Daftar Dokumen'
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce; // Untuk menunda search agar tidak spam API

  // --- DATA ---
  List<DocumentModel> _documents = []; // List Data yang tampil (bertambah terus)
  
  // --- STATE ---
  bool _isLoading = false;      // Loading saat fetch data
  bool _isFirstLoad = true;     // Loading awal buka halaman
  bool _hasMore = true;         // Apakah masih ada data di server?
  
  // --- PAGINATION CONFIG ---
  int _currentPage = 1;
  final int _limit = 10;

  // --- FILTER ---
  List<String> _typeChips = ['Semua'];
  String _selectedChip = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadChips();
    _fetchDocuments(); // Load data pertama

    // Listener untuk mendeteksi scroll mentok bawah
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Jika sisa scroll tinggal 200px lagi, load halaman berikutnya
        if (!_isLoading && _hasMore) {
          _fetchDocuments();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- CORE LOGIC: FETCH DATA DARI API ---
  Future<void> _fetchDocuments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Tentukan Kategori gabungan (Dari Menu Home + Chip Filter)
      String categoryParam = '';
      
      // 1. Cek Filter Bawaan Menu Home (widget.categoryFilter)
      if (widget.categoryFilter != null) {
        categoryParam = widget.categoryFilter!; 
        // Note: Logic mapping (PRODUK_HUKUM -> PERATURAN/KEPUTUSAN) sebaiknya dihandle di Backend
        // Atau kirim raw code-nya biar backend yang filter.
      }

      // 2. Cek Filter Chips (User milih manual)
      if (_selectedChip != 'Semua') {
        // Jika user memilih chip spesifik, timpa kategori filter
        categoryParam = _selectedChip;
      }

      // Panggil API
      final newDocs = await _apiService.getDocuments(
        page: _currentPage,
        limit: _limit,
        search: _searchController.text, // Kirim text search
        category: categoryParam,        // Kirim kategori
      );

      if (mounted) {
        setState(() {
          _currentPage++; // Siapkan halaman selanjutnya
          _isLoading = false;
          _isFirstLoad = false;

          // Jika data yang didapat kurang dari limit, berarti sudah habis
          if (newDocs.length < _limit) {
            _hasMore = false;
          }

          _documents.addAll(newDocs); // Gabungkan data baru ke list lama
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFirstLoad = false;
        });
        // Tampilkan error jika perlu
      }
    }
  }

  // --- LOGIC RESET: Dipanggil saat Search / Ganti Filter ---
  void _resetAndReload() {
    setState(() {
      _documents.clear();   // Kosongkan list
      _currentPage = 1;     // Reset ke halaman 1
      _hasMore = true;      // Reset status
      _isFirstLoad = true;  // Tampilkan loading awal lagi
    });
    _fetchDocuments();
  }

  // Logic Debounce Search (Agar tidak hit API setiap ketik 1 huruf)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetAndReload();
    });
  }

  Future<void> _loadChips() async {
    if (widget.categoryFilter == 'PRODUK_HUKUM') {
      try {
        final types = await _apiService.getDocumentTypes();
        if (mounted) setState(() => _typeChips = ['Semua', ...types]);
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.pageTitle, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. HEADER SEARCH
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF1a237e),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged, // Pakai debounce logic
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari judul, nomor, atau tahun...',
                hintStyle: GoogleFonts.lato(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          // 2. FILTER CHIPS
          if (_typeChips.length > 1)
            Container(
              height: 60,
              margin: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _typeChips.length,
                itemBuilder: (context, index) {
                  final type = _typeChips[index];
                  final isSelected = _selectedChip == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedChip = type;
                            _resetAndReload(); // Reload data sesuai filter baru
                          });
                        }
                      },
                      selectedColor: const Color(0xFF1a237e),
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.lato(color: isSelected ? Colors.white : const Color(0xFF1a237e), fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
                    ),
                  );
                },
              ),
            ),

          // 3. LIST DOKUMEN (LAZY LOAD)
          Expanded(
            child: _isFirstLoad 
              ? const Center(child: CircularProgressIndicator()) 
              : _documents.isEmpty
                ? Center(child: Text("Data tidak ditemukan", style: GoogleFonts.lato(color: Colors.grey)))
                : ListView.builder(
                    controller: _scrollController, // <--- PENTING: Controller Scroll
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    // +1 item untuk loading indicator di paling bawah
                    itemCount: _documents.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Jika index sudah di ujung list, tampilkan loading kecil
                      if (index == _documents.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      
                      return _buildDocumentCard(_documents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD (Sama persis, tidak ada perubahan)
  Widget _buildDocumentCard(DocumentModel doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.description_outlined, color: Color(0xFF1565C0), size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                            child: Text(doc.jenisDokumen.toUpperCase(), style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
                          ),
                          const SizedBox(height: 8),
                          Text(doc.judul, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                Row(
                  children: [
                    Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]), const SizedBox(width: 4), Text(doc.tahun, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[700]))]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: doc.status == 'Berlaku' ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: doc.status == 'Berlaku' ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(doc.status, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: doc.status == 'Berlaku' ? Colors.green[700] : Colors.red[700])),
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