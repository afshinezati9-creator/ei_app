import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/data_provider.dart';
import '../providers/currency_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currency = context.watch<CurrencyProvider>();

    final income = data.getTotalByType('income');
    final expense = data.getTotalByType('expense');
    final saving = data.getTotalByType('saving');
    final debt = data.getTotalByType('debt') + data.getTotalByType('loan');
    final balance = income - expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('آمار'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== خلاصه آمار =====
            Row(
              children: [
                _statBox('موجودی', currency.formatCurrency(balance), balance >= 0 ? Colors.green : Colors.red),
                const SizedBox(width: 10),
                _statBox('درآمد', currency.formatCurrency(income), Colors.green),
                const SizedBox(width: 10),
                _statBox('مخارج', currency.formatCurrency(expense), Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statBox('پس‌انداز', currency.formatCurrency(saving), Colors.blue),
                const SizedBox(width: 10),
                _statBox('قرض + وام', currency.formatCurrency(debt), Colors.orange),
                const SizedBox(width: 10),
                _statBox('تعداد تراکنش', data.transactions.length.toString(), Colors.purple),
              ],
            ),

            const SizedBox(height: 20),

            // ===== نمودار میله‌ای =====
            if (income > 0 || expense > 0)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (income > expense ? income : expense) * 1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              currency.formatNumber(value),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = ['درآمد', 'مخارج'];
                            if (value.toInt() < titles.length) {
                              return Text(
                                titles[value.toInt()],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: income > 0 ? income : 1,
                            color: Colors.green,
                            width: 30,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: expense > 0 ? expense : 1,
                            color: Colors.red,
                            width: 30,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}