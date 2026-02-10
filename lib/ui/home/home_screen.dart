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
  
  // WARNA TEMA BARU (Sesuai Website JDIH Kendari)
  final Color _primaryDark = const Color(0xFF111827); // Biru Gelap (Header)
  final Color _accentOrange = const Color(0xFFF97316); // Oranye (Search & Aksen)
  
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

  // FUNGSI POPUP FILTER
  void _showFilterOptions() {
    final List<String> years = ["Semua", ...List.generate(27, (index) => (2026 - index).toString())];
    
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 25, 
                right: 25, 
                top: 25, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 25 
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Filter Spesifik", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark)),
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
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentOrange, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
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
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentOrange, width: 2)),
                                ),
                                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) => setModalState(() => _selectedTahun = val!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
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
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentOrange, width: 2)),
                                ),
                                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) => setModalState(() => _selectedJenis = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
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
                                filterJenis: _selectedJenis,
                                categoryFilter: "ALL",
                              ),
                            ),
                          );
                        },
                        child: Text("Terapkan Filter", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFF3F4F6), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER & SEARCH
            _buildHeaderSearch(context),
            
            const SizedBox(height: 25),

            // 2. MENU UTAMA
            _buildSectionTitle("Menu Utama"),
            const SizedBox(height: 10),
            _buildMainButton(context),

            const SizedBox(height: 30),

            // 3. DASHBOARD STATISTIK
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: _primaryDark)
                    ),
                    Text(
                      "Update: ${_stats!.lastUpdated}",
                      style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400]),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _primaryDark.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.bar_chart_rounded, color: _primaryDark, size: 28),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        StatistikTipeSlider(dataTipe: _stats!.perTipe),
        const SizedBox(height: 20),
        StatistikChartTahun(dataTahun: _stats!.perTahun),
        const SizedBox(height: 20),
        StatistikChartStatus(dataStatus: _stats!.perStatus),
      ],
    );
  }

  // --- HEADER SEARCH (REVISI: WARNA BARU + 2 LOGO) ---
  Widget _buildHeaderSearch(BuildContext context) {
    return Stack(
      children: [
        // BACKGROUND HEADER (BIRU GELAP WEB)
        Container(
          height: 230,
          decoration: BoxDecoration(
            color: _primaryDark, 
            image: const DecorationImage(
              image: AssetImage('assets/images/logo.png'), 
              opacity: 0.05, 
              fit: BoxFit.cover, 
            ),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
          ),
          child: Stack(
            children: [
              Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle))),
              Positioned(bottom: 20, left: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), shape: BoxShape.circle))),
              
              Padding(
                 padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // LOGO 1: JDIH (logo.png)
                        Container(
                          padding: const EdgeInsets.all(6), // Padding diperkecil sedikit biar muat
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Image.asset(
                            'assets/images/logo.png', 
                            height: 30, 
                            width: 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white60, size: 20),
                          ),
                        ),
                        
                        const SizedBox(width: 8), // Jarak antar logo

                        // LOGO 2: LOGO KENDARI (logo_kendari.png)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Image.asset(
                            'assets/images/logo_kendari.png', // Pastikan file ini ada di folder assets/images/
                            height: 30, 
                            width: 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.white60, size: 20),
                          ),
                        ),

                        const SizedBox(width: 12),
                        
                        // JUDUL (Teks Putih)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "JDIH Kota Kendari",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text("Jaringan Dokumentasi Hukum", style: GoogleFonts.lato(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // TAGLINE ADAT
                    Text(
                      "Inae konasara ie'e pinesara inae lia", 
                      style: GoogleFonts.playfairDisplay(
                        color: _accentOrange, 
                        fontSize: 14, 
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                      "Siapa yang menghargai adat ia akan dihormati", 
                      style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // SEARCH BAR
        Container(
          margin: const EdgeInsets.only(top: 195, left: 25, right: 25),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Icon(Icons.search_rounded, color: Colors.grey[400], size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController, 
                  onSubmitted: (_) => _performSearch(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Cari peraturan...",
                    hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14)
                  ),
                ),
              ),
              // TOMBOL FILTER (ORANYE)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showFilterOptions, 
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10), 
                    decoration: BoxDecoration(
                      color: _accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune_rounded, color: _accentOrange, size: 22),
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
          Container(height: 20, width: 4, decoration: BoxDecoration(color: _accentOrange, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark)),
        ],
      ),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 110, 
      decoration: BoxDecoration(
        // GRADASI UNGU GELAP (Mirip WEB)
        gradient: LinearGradient(
          colors: [_primaryDark, const Color(0xFF312E81)], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentListScreen(categoryFilter: "ALL", pageTitle: "Produk Hukum Daerah")));
          },
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), 
                  child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 32)
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Text("Jelajahi Produk Hukum", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("Cari Perda, Perwali, SK, dll", style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),
                  ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8), 
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), 
                  child: Icon(Icons.arrow_forward_rounded, color: _primaryDark, size: 18)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}