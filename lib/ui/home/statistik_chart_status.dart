import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/statistic_model.dart';

class StatistikChartStatus extends StatelessWidget {
  final List<StatistikItem> dataStatus;

  const StatistikChartStatus({super.key, required this.dataStatus});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    const Color primaryDark = Color(0xFF111827);
    const Color accentOrange = Color(0xFFF97316);
    const Color successGreen = Color(0xFF10B981); // Hijau Emerald Modern

    // Cari data Berlaku dan Tidak Berlaku
    int berlaku = 0;
    int tidakBerlaku = 0;

    for (var item in dataStatus) {
      if (item.label.toLowerCase().contains("tidak berlaku") || item.label.toLowerCase().contains("dicabut")) {
        tidakBerlaku += item.total;
      } else {
        berlaku += item.total;
      }
    }

    final int total = berlaku + tidakBerlaku;
    // Hitung Persentase
    final double persenBerlaku = total > 0 ? (berlaku / total) * 100 : 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Shadow konsisten dengan chart tahun
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status Dokumen", 
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: primaryDark
                )
              ),
              Icon(Icons.pie_chart_rounded, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(height: 30),
          
          Row(
            children: [
              // 1. PIE CHART
              SizedBox(
                height: 130,
                width: 130,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2, // Ada jarak dikit antar slice biar rapi
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    sections: [
                      // Bagian Berlaku (Hijau)
                      PieChartSectionData(
                        color: successGreen,
                        value: berlaku.toDouble(),
                        title: '${persenBerlaku.toStringAsFixed(0)}%',
                        radius: 25,
                        titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      // Bagian Tidak Berlaku (Oranye/Merah)
                      PieChartSectionData(
                        color: accentOrange,
                        value: tidakBerlaku.toDouble(),
                        title: '', // Tidak perlu teks kalau kecil
                        radius: 18, // Sedikit lebih kecil biar artistik
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 25),
              
              // 2. KETERANGAN (LEGEND)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem("Berlaku", berlaku, successGreen, primaryDark),
                    const SizedBox(height: 15),
                    _buildLegendItem("Dicabut / Tidak Berlaku", tidakBerlaku, accentOrange, primaryDark),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: GoogleFonts.lato(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)
              ),
              Text(
                "$count Dokumen", 
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)
              ),
            ],
          ),
        ),
      ],
    );
  }
}