import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/statistic_model.dart';

class StatistikChartTahun extends StatelessWidget {
  final List<StatistikItem> dataTahun;

  const StatistikChartTahun({super.key, required this.dataTahun});

  @override
  Widget build(BuildContext context) {
    // Balik data agar tahun lama di kiri, tahun baru di kanan
    final List<StatistikItem> sortedData = List.from(dataTahun.reversed);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
                  color: const Color(0xFF1a237e)
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text("Per Tahun", style: GoogleFonts.lato(fontSize: 10, color: Colors.blue.shade900)),
              )
            ],
          ),
          const SizedBox(height: 25),

          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(sortedData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // PERBAIKAN DI SINI (Pakai tooltipBgColor agar aman di versi lama/baru)
                    tooltipBgColor: const Color(0xFF1a237e), 
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${sortedData[group.x.toInt()].label}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        children: [
                          TextSpan(
                            text: (rod.toY.toInt()).toString(),
                            style: const TextStyle(color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.w900),
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
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedData.length) return const SizedBox.shrink();
                        
                        final label = sortedData[index].label;
                        final shortLabel = label.length > 2 ? "'${label.substring(2)}" : label;
                        
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            shortLabel, 
                            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[600])
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: sortedData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.total.toDouble(),
                        color: index == sortedData.length - 1 
                            ? const Color(0xFFFB8C00) 
                            : const Color(0xFF3949AB), 
                        width: 12,
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
    return (maxVal * 1.2).toDouble();
  }
}