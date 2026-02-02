import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../produk_hukum/document_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    // --- DATA ITEM ---

    // 1. ITEM ATAS (PUU)
    final Map<String, dynamic> infoTop = {
      "label": "Pembentukan PUU",
      "icon": Icons.balance_rounded, 
      "color": const Color(0xFF3949AB), 
    };

    // 2. ITEM BAWAH (GRID 4)
    final List<Map<String, dynamic>> infoBottom = [
      {
        "label": "Propemperda",
        "icon": Icons.menu_book_rounded, 
        "color": const Color(0xFF00897B), 
      },
      {
        "label": "Propemperkada",
        "icon": Icons.assignment_turned_in_rounded, 
        "color": const Color(0xFFFB8C00), 
      },
      {
        "label": "Ranperda",
        "icon": Icons.history_edu_rounded, 
        "color": const Color(0xFF5E35B1), 
      },
      {
        "label": "Ranperwali",
        "icon": Icons.edit_document, 
        "color": const Color(0xFFE53935), 
      },
    ];

    // DATA BERITA
    final List<Map<String, String>> beritaList = [
      {"judul": "Kota Kendari Raih Penghargaan JDIH Terbaik Tingkat Nasional", "tanggal": "27 Jan 2026", "kategori": "Prestasi"},
      {"judul": "DPRD Sahkan 3 Rancangan Peraturan Daerah Menjadi Perda", "tanggal": "25 Jan 2026", "kategori": "Legislasi"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER 
            _buildHeaderSearch(context),
            
            const SizedBox(height: 30),

            // TOMBOL UTAMA (PRODUK HUKUM)
            _buildSectionTitle("Menu Utama"),
            const SizedBox(height: 10), // Jarak dirapatkan sedikit
            _buildMainButton(context),

            const SizedBox(height: 25),

            // INFORMASI HUKUM
            _buildSectionTitle("Informasi Hukum"),
            
            // Jarak antara Judul dan Card PUU dirapatkan (dari 15 ke 10)
            const SizedBox(height: 10), 
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // A. Item Atas (PUU)
                  _buildSingleTopItemVisual(context, infoTop),
                  
                  // Jarak antara PUU dan Grid bawah dirapatkan (dari 15 ke 8)
                  const SizedBox(height: 8),
                  
                  // B. Grid Bawah (Propemperda, dll)
                  _buildBottomGridItemsVisual(context, infoBottom),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // DISABILITAS
            _buildDisabilitasCard(),

            const SizedBox(height: 30),

            // BERITA
             _buildSectionHeaderWithAction("Berita Terkini", onTap: () {}),
             const SizedBox(height: 10),
            _buildBeritaList(beritaList),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER ---
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
              Positioned(
                top: -50, right: -50,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                ),
              ),
              Positioned(
                bottom: 20, left: -30,
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                ),
              ),
              Padding(
                 padding: const EdgeInsets.fromLTRB(25, 70, 25, 20),
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("JDIH Kota Kendari", style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text("Selamat datang di portal hukum daerah", style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        ),
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
              const Icon(Icons.search_rounded, color: Colors.grey, size: 26),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari peraturan, keputusan...",
                    hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade200)),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF1a237e)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET JUDUL ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Container(
            height: 20, width: 4,
            decoration: BoxDecoration(color: const Color(0xFF1a237e), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
        ],
      ),
    );
  }

  // --- WIDGET ITEM ATAS VISUAL (NAVIGASI DITAMBAHKAN) ---
  Widget _buildSingleTopItemVisual(BuildContext context, Map<String, dynamic> item) {
    final Color accentColor = item['color'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          // Tambahkan Navigasi
          onTap: () {
             Navigator.push(context, MaterialPageRoute(
               builder: (context) => DocumentListScreen(
                 categoryFilter: "PUU", // Filter khusus PUU
                 pageTitle: item['label']
               )
             ));
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(item['icon'], color: accentColor, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'],
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Proses pembentukan peraturan",
                        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }

   // --- WIDGET GRID BAWAH VISUAL (NAVIGASI DITAMBAHKAN) ---
  Widget _buildBottomGridItemsVisual(
      BuildContext context, List<Map<String, dynamic>> data) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.6, 
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final Color accentColor = item['color'];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              // Tambahkan Navigasi
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => DocumentListScreen(
                    categoryFilter: item['label'], // Kirim label sebagai filter
                    pageTitle: item['label']
                  )
                ));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['label'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TOMBOL UTAMA ---
  Widget _buildMainButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 110, 
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Produk Hukum", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("Cari Perda, Perwali, SK, dll", style: GoogleFonts.lato(fontSize: 13, color: Colors.white.withOpacity(0.95))),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeaderWithAction(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Row(
            children: [
              Container(height: 20, width: 4, decoration: BoxDecoration(color: const Color(0xFF1a237e), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
            ],
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Text("Lihat Semua", style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF1565C0))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDisabilitasCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFAD1457), Color(0xFFEC407A)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFFAD1457).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Layanan Disabilitas", style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("Akses mudah untuk semua", style: GoogleFonts.lato(color: Colors.white.withOpacity(0.95), fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildBeritaList(List<Map<String, String>> data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 85, height: 85,
                  color: Colors.grey[100],
                  child: Icon(Icons.image_rounded, color: Colors.grey[300], size: 32),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                      child: Text(item['kategori']!, style: GoogleFonts.lato(fontSize: 11, color: const Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text(item['judul']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Text(item['tanggal']!, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}