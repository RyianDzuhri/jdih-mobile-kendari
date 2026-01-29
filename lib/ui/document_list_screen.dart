import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/document_model.dart';
import 'document_detail_screen.dart';

class DocumentListScreen extends StatefulWidget {
  final String? categoryFilter;
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

  // --- DATA ---
  List<DocumentModel> _allDocs = [];        // Master Data (Semua dari API)
  List<DocumentModel> _filteredDocs = [];   // Data hasil filter (Search/Kategori)
  List<DocumentModel> _pagedDocs = [];      // Data yang TAMPIL di halaman saat ini (10 biji)

  // --- PAGINATION CONFIG ---
  int _currentPage = 1;                     // Halaman aktif
  final int _itemsPerPage = 10;             // Jumlah per halaman (mirip web)
  int _totalPages = 0;                      // Total halaman

  // --- CHIPS & LOADING ---
  List<String> _typeChips = ['Semua'];
  String _selectedChip = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      _loadDocuments(),
      _loadChips(),
    ]);
  }

  // 1. LOAD DATA DARI SERVER
  Future<void> _loadDocuments() async {
    try {
      final docs = await _apiService.getDocuments();
      
      // Filter Awal (Kategori Menu)
      List<DocumentModel> initialFilter = [];
      if (widget.categoryFilter != null) {
        initialFilter = docs.where((doc) {
          final jenis = doc.jenisDokumen.toUpperCase();
          final code = widget.categoryFilter!.toUpperCase();
          if (code == 'PRODUK_HUKUM') return jenis.contains('PERATURAN') || jenis.contains('KEPUTUSAN');
          if (code == 'MONOGRAFI') return jenis.contains('MONOGRAFI') || jenis.contains('BUKU');
          if (code == 'ARTIKEL') return jenis.contains('ARTIKEL') || jenis.contains('MAJALAH');
          if (code == 'PUTUSAN') return jenis.contains('PUTUSAN');
          return jenis.contains(code);
        }).toList();
      } else {
        initialFilter = docs;
      }

      if (mounted) {
        setState(() {
          _allDocs = docs;
          _filteredDocs = initialFilter;
          _isLoading = false;
        });
        // Hitung halaman awal
        _updatePagination(); 
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChips() async {
    if (widget.categoryFilter == 'PRODUK_HUKUM') {
      try {
        final types = await _apiService.getDocumentTypes();
        if (mounted) setState(() => _typeChips = ['Semua', ...types]);
      } catch (e) {}
    }
  }

  // 2. LOGIKA PEMOTONGAN HALAMAN (CORE PAGINATION)
  void _updatePagination() {
    // Hitung total halaman
    _totalPages = (_filteredDocs.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    // Pastikan halaman aktif tidak melebihi total
    if (_currentPage > _totalPages) _currentPage = _totalPages;
    if (_currentPage < 1) _currentPage = 1;

    // Potong Data (Slice)
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    
    // Cegah index out of bound
    if (startIndex >= _filteredDocs.length) {
      _pagedDocs = [];
    } else {
      if (endIndex > _filteredDocs.length) endIndex = _filteredDocs.length;
      _pagedDocs = _filteredDocs.sublist(startIndex, endIndex);
    }
  }

  // Fungsi Pindah Halaman
  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
      _updatePagination();
    });
    // Opsional: Scroll ke atas saat ganti halaman
    // _scrollController.jumpTo(0);
  }

  // 3. LOGIKA FILTER
  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    
    List<DocumentModel> source = _allDocs;

    // Ulangi Filter Kategori
    if (widget.categoryFilter != null) {
       source = source.where((doc) {
          final jenis = doc.jenisDokumen.toUpperCase();
          final code = widget.categoryFilter!.toUpperCase();
          if (code == 'PRODUK_HUKUM') return jenis.contains('PERATURAN') || jenis.contains('KEPUTUSAN');
          if (code == 'MONOGRAFI') return jenis.contains('MONOGRAFI') || jenis.contains('BUKU');
          if (code == 'ARTIKEL') return jenis.contains('ARTIKEL') || jenis.contains('MAJALAH');
          if (code == 'PUTUSAN') return jenis.contains('PUTUSAN');
          return jenis.contains(code);
       }).toList();
    }

    // Filter Chips
    if (_selectedChip != 'Semua') {
      source = source.where((doc) => doc.jenisDokumen.toUpperCase() == _selectedChip.toUpperCase()).toList();
    }

    // Filter Search
    if (query.isNotEmpty) {
      source = source.where((doc) =>
        doc.judul.toLowerCase().contains(query) ||
        doc.nomorPeraturan.toLowerCase().contains(query) ||
        doc.tahun.contains(query)
      ).toList();
    }

    setState(() {
      _filteredDocs = source;
      _currentPage = 1; // Reset ke halaman 1 setiap kali filter berubah
      _updatePagination();
    });
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
          // HEADER SEARCH
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF1a237e),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _runFilter(),
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

          // FILTER CHIPS
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
                            _runFilter();
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

          // LIST DOKUMEN
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDocs.isEmpty
                ? Center(child: Text("Data tidak ditemukan", style: GoogleFonts.lato(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    itemCount: _pagedDocs.length,
                    itemBuilder: (context, index) => _buildDocumentCard(_pagedDocs[index]),
                  ),
          ),

          // --- TOMBOL NAVIGASI HALAMAN (FOOTER) ---
          if (!_isLoading && _filteredDocs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol PREV
                  ElevatedButton(
                    onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1a237e),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFF1a237e)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.arrow_back_ios, size: 16),
                  ),

                  // Indikator Halaman
                  Text(
                    "Halaman $_currentPage dari $_totalPages",
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),

                  // Tombol NEXT
                  ElevatedButton(
                    onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a237e),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // WIDGET CARD (Tetap Sama)
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