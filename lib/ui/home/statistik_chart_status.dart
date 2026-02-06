import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/statistic_model.dart';

class StatistikChartStatus extends StatelessWidget {
  final List<StatistikItem> dataStatus;

  const StatistikChartStatus({super.key, required this.dataStatus});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Status Dokumen", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e))),
              Icon(Icons.pie_chart_rounded, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              // 1. PIE CHART
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      // Bagian Berlaku (Hijau)
                      PieChartSectionData(
                        color: const Color(0xFF4CAF50),
                        value: berlaku.toDouble(),
                        title: '${persenBerlaku.toStringAsFixed(0)}%',
                        radius: 20,
                        titleStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      // Bagian Tidak Berlaku (Merah)
                      PieChartSectionData(
                        color: const Color(0xFFE53935),
                        value: tidakBerlaku.toDouble(),
                        title: '',
                        radius: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // 2. KETERANGAN (LEGEND)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem("Berlaku", berlaku, const Color(0xFF4CAF50)),
                    const SizedBox(height: 12),
                    _buildLegendItem("Tidak Berlaku", tidakBerlaku, const Color(0xFFE53935)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 13)),
        ),
        Text("$count", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}