import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Model & Service
import '../../models/statistic_model.dart';
import '../../services/jdih_service.dart';

// Import Screen & Widget
import '../produk_hukum/document_list_screen.dart';
import 'statistik_chart_tahun.dart'; 
import 'statistik_chart_status.dart';
import 'statistik_tipe_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final JdihService _service = JdihService();
  
  // VARIABLE STATISTIK
  StatisticModel? _stats;
  bool _isLoading = true;

  // VARIABLE FILTER POPUP
  String _selectedTahun = "Semua";
  String _selectedJenis = "Semua";
  final TextEditingController _nomorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStatsOnly();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nomorController.dispose();
    super.dispose();
  }

  Future<void> _loadStatsOnly() async {
    try {
      final stats = await _service.getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading stats: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentListScreen(
            pageTitle: "Pencarian: $query",
            searchQuery: query,
            categoryFilter: "ALL",
          ),
        ),
      );
    }
  }

  // FUNGSI POPUP FILTER CANGGIH
  // FUNGSI POPUP FILTER (VERSI ANTI ERROR / RESPONSIF)
  // FUNGSI POPUP FILTER (DENGAN TIPE DOKUMEN YANG BENAR)
  void _showFilterOptions() {
    // 1. Daftar Tahun (2026 mundur sampai 2000)
    final List<String> years = ["Semua", ...List.generate(27, (index) => (2026 - index).toString())];
    
    // 2. Daftar Jenis Dokumen (Sesuai Data JSON kamu)
    final List<String> types = [
      "Semua",
      "ANALISIS DAN EVALUASI",
      "ARTIKEL HUKUM",
      "BUKU HUKUM",
      "KEPUTUSAN DPRD",
      "KEPUTUSAN WALIKOTA",
      "NASKAH AKADEMIK",
      "OPINI PAKAR HUKUM",
      "PENGKAJIAN HUKUM",
      "PENULISAN KARYA ILMIAH",
      "PERATURAN BERSAMA GUBERNUR",
      "PERATURAN DAERAH KOTA",
      "PERATURAN WALIKOTA",
      "PUTUSAN",
      "PUTUSAN MAHKAMAH AGUNG"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa full screen/naik saat keyboard muncul
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 25, 
                right: 25, 
                top: 25, 
                // Padding bawah dinamis agar naik saat keyboard muncul
                bottom: MediaQuery.of(context).viewInsets.bottom + 25 
              ),
              child: SingleChildScrollView( // Bungkus ScrollView agar tidak overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Filter Spesifik", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _nomorController.clear();
                              _selectedTahun = "Semua";
                              _selectedJenis = "Semua";
                            });
                          },
                          child: const Text("Reset", style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- 1. Input Nomor ---
                    Text("Nomor Dokumen", style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomorController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Contoh: 14",
                        isDense: true, 
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    
                    const SizedBox(height: 15),

                    // --- 2. Input Tahun & Jenis ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        // BAGIAN TAHUN
                        Expanded(
                          flex: 4, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tahun", style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedTahun,
                                isExpanded: true, 
                                decoration: InputDecoration(
                                  isDense: true, 
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) => setModalState(() => _selectedTahun = val!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        // BAGIAN JENIS (Updated List)
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Jenis Dokumen", style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedJenis,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  isDense: true, 
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                // Menggunakan list types yang baru
                                items: types.map((t) => DropdownMenuItem(
                                  value: t, 
                                  child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))
                                )).toList(),
                                onChanged: (val) => setModalState(() => _selectedJenis = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // --- Tombol Terapkan ---
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1a237e),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentListScreen(
                                pageTitle: "Hasil Filter",
                                searchQuery: _searchController.text,
                                filterNomor: _nomorController.text,
                                filterTahun: _selectedTahun,
                                filterJenis: _selectedJenis, // Mengirim jenis yang dipilih
                                categoryFilter: "ALL",
                              ),
                            ),
                          );
                        },
                        child: Text("Terapkan Filter", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER & SEARCH
            _buildHeaderSearch(context),
            
            const SizedBox(height: 25),

            // 2. MENU UTAMA (POSISI DI ATAS)
            _buildSectionTitle("Menu Utama"),
            const SizedBox(height: 10),
            _buildMainButton(context),

            const SizedBox(height: 30),

            // 3. DASHBOARD STATISTIK (POSISI DI BAWAH)
            _buildSectionTitle("Dashboard Data"),
            const SizedBox(height: 10),
            _buildStatistikSection(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGET STATISTIK ---
  Widget _buildStatistikSection() {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    
    if (_stats == null) return const SizedBox.shrink(); 

    return Column(
      children: [
        // A. Ringkasan Total
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Dokumen", style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      "${_stats!.totalDokumen}", 
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))
                    ),
                    Text(
                      "Update: ${_stats!.lastUpdated}",
                      style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400]),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF1a237e), size: 28),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // B. Slider Kategori
        StatistikTipeSlider(dataTipe: _stats!.perTipe),
        
        const SizedBox(height: 20),
        
        // C. Chart Tahunan
        StatistikChartTahun(dataTahun: _stats!.perTahun),
        
        const SizedBox(height: 20),
        
        // D. Chart Status
        StatistikChartStatus(dataStatus: _stats!.perStatus),
      ],
    );
  }

  // --- HEADER SEARCH ---
  // --- HEADER SEARCH (TANPA NOTIFIKASI) ---
  Widget _buildHeaderSearch(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            color: Color(0xFF1a237e),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
          ),
          child: Stack(
            children: [
              Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
              Positioned(bottom: 20, left: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
              Padding(
                 padding: const EdgeInsets.fromLTRB(25, 70, 25, 20),
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // LOGO
                                  Image.asset(
                                    'assets/images/logo.png', 
                                    height: 32, 
                                    width: 32,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, color: Colors.white60, size: 30);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  // JUDUL
                                  Expanded(
                                    child: Text(
                                      "JDIH Kota Kendari",
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                      maxLines: 2, 
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text("Selamat datang di portal hukum daerah", style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                            ],
                          ),
                        ),
                        // BAGIAN ICON NOTIFIKASI SUDAH DIHAPUS DARI SINI
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 185, left: 25, right: 25),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF1a237e).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              InkWell(
                onTap: _performSearch,
                child: const Icon(Icons.search_rounded, color: Colors.grey, size: 26)
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _searchController, 
                  onSubmitted: (_) => _performSearch(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Cari peraturan, keputusan...",
                    hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                ),
              ),
              // TOMBOL FILTER (TUNE)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showFilterOptions, 
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12), 
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF1a237e)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Container(height: 20, width: 4, decoration: BoxDecoration(color: const Color(0xFF1a237e), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
        ],
      ),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 110, 
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentListScreen(categoryFilter: "ALL", pageTitle: "Produk Hukum Daerah")));
          },
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 36)),
                const SizedBox(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Produk Hukum", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("Cari Perda, Perwali, SK, dll", style: GoogleFonts.lato(fontSize: 13, color: Colors.white.withOpacity(0.95))),
                  ]),
                const Spacer(),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}