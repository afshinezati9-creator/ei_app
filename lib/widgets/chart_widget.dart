import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class ChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final ChartType type;

  const ChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.type = ChartType.pie,
  });

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFF0984E3),
      const Color(0xFF00B894),
      const Color(0xFFFDCB6E),
      const Color(0xFFE84393),
      const Color(0xFFF39C12),
    ];

    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'داده‌ای برای نمایش وجود ندارد',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);

    if (type == ChartType.pie) {
      return _buildPieChart(entries, colors, currency, isDark);
    } else {
      return _buildBarChart(entries, colors, currency, isDark);
    }
  }

  Widget _buildPieChart(
    List<MapEntry<String, double>> entries,
    List<Color> colors,
    CurrencyProvider currency,
    bool isDark,
  ) {
    final total = entries.fold(0.0, (a, b) => a + b.value);

    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final percentage = total > 0 ? (item.value / total) : 0;
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: item.value,
                    title: '${(percentage * 100).toInt()}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: entries.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final percentage = total > 0 ? (item.value / total) * 100 : 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors[index % colors.length].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.key}: ${currency.formatNumber(item.value)} (${percentage.toInt()}%)',
                  style: TextStyle(
                    fontSize: 10,
                    color: colors[index % colors.length],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    List<MapEntry<String, double>> entries,
    List<Color> colors,
    CurrencyProvider currency,
    bool isDark,
  ) {
    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue > 0 ? maxValue * 1.2 : 100.0; // تبدیل به double

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: safeMax,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          currency.formatNumber(value),
                          style: const TextStyle(fontSize: 8),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < entries.length) {
                          return Text(
                            entries[value.toInt()].key,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.value > 0 ? item.value : 1,
                        color: colors[index % colors.length],
                        width: 30,
                        borderRadius: BorderRadius.circular(6),
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
}

enum ChartType {
  pie,
  bar,
}