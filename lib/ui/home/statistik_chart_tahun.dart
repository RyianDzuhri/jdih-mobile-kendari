import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/statistic_model.dart';

class StatistikChartTahun extends StatelessWidget {
  final List<StatistikItem> dataTahun;

  const StatistikChartTahun({super.key, required this.dataTahun});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    const Color primaryDark = Color(0xFF111827);
    const Color accentOrange = Color(0xFFF97316);

    // Balik data agar tahun lama di kiri, tahun baru di kanan
    final List<StatistikItem> sortedData = List.from(dataTahun.reversed);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tren Dokumen",
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: primaryDark
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("Per Tahun", style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: accentOrange)),
              )
            ],
          ),
          const SizedBox(height: 30),

          AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(sortedData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: primaryDark, 
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${sortedData[group.x.toInt()].label}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        children: [
                          TextSpan(
                            text: (rod.toY.toInt()).toString(),
                            style: const TextStyle(color: accentOrange, fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Left Axis
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30, // Space buat teks tahun
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedData.length) return const SizedBox.shrink();
                        
                        final label = sortedData[index].label;
                        // Ambil 2 digit terakhir (misal '26 dari 2026)
                        final shortLabel = label.length > 2 ? "'${label.substring(2)}" : label;
                        
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            shortLabel, 
                            style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20, // Garis horizontal tipis per 20 unit
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                barGroups: sortedData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == sortedData.length - 1; // Tahun terbaru

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.total.toDouble(),
                        color: isLast ? accentOrange : primaryDark, // Highlight tahun terbaru
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxY(sortedData),
                          color: Colors.grey.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<StatistikItem> list) {
    if (list.isEmpty) return 10;
    int maxVal = list.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    // Tambah buffer 20% di atas max value biar grafik ga mentok atas
    return (maxVal * 1.2).toDouble();
  }
}