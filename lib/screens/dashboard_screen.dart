// farhanfarruq/personal_finance/personal_finance-9dc4a3471684685b48bafc19424765a788b29d69/lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';

enum ChartType { column, pie, line }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ChartType _selectedChart = ChartType.column;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Keuangan'),
        backgroundColor: Colors.teal.shade50,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Analisis Bulan ${prov.monthLabel}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visualisasikan data keuangan Anda dalam berbagai bentuk grafik.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SegmentedButton<ChartType>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: Colors.teal.withOpacity(0.2),
              selectedForegroundColor: Colors.teal,
            ),
            segments: const [
              ButtonSegment(
                  value: ChartType.column,
                  label: Text('Column'),
                  icon: Icon(Icons.bar_chart)),
              ButtonSegment(
                  value: ChartType.pie,
                  label: Text('Pie'),
                  icon: Icon(Icons.pie_chart_outline)),
              ButtonSegment(
                  value: ChartType.line,
                  label: Text('Line'),
                  icon: Icon(Icons.show_chart)),
            ],
            selected: {_selectedChart},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedChart = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 350,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildChart(prov, currency),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan pesan saat data kosong
  Widget _buildEmptyState() {
    return const Center(
      key: ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.data_usage_rounded, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak Ada Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(
            'Grafik akan muncul setelah ada transaksi.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(FinanceProvider prov, NumberFormat currency) {
    switch (_selectedChart) {
      case ChartType.column:
        return _buildBarChart(prov, currency);
      case ChartType.pie:
        return _buildPieChart(prov, currency);
      case ChartType.line:
        return _buildLineChart(prov, currency);
    }
  }

  Widget _buildBarChart(FinanceProvider prov, NumberFormat currency) {
    final data = prov.expenseByCategory;
    if (data.isEmpty) return _buildEmptyState();

    return BarChart(
      key: const ValueKey('bar'),
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: data.values.reduce((a, b) => a > b ? a : b) / 4),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(data.keys.elementAt(value.toInt()).icon, style: const TextStyle(fontSize: 24)),
              reservedSize: 32,
            ),
          ),
        ),
        barGroups: List.generate(data.length, (index) {
          final entry = data.entries.elementAt(index);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.teal,
                width: 22,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart(FinanceProvider prov, NumberFormat currency) {
    final data = prov.expenseByCategory;
    if (data.isEmpty) return _buildEmptyState();

    final totalExpense = data.values.fold(0.0, (sum, item) => sum + item);

    return PieChart(
      key: const ValueKey('pie'),
      PieChartData(
        sections: List.generate(data.length, (index) {
          final entry = data.entries.elementAt(index);
          final percentage = (entry.value / totalExpense) * 100;
          return PieChartSectionData(
            value: entry.value,
            title: '${entry.key.icon}\n${percentage.toStringAsFixed(0)}%',
            color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.8),
            radius: 100,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
          );
        }),
        centerSpaceRadius: 40,
        sectionsSpace: 4,
      ),
    );
  }

  Widget _buildLineChart(FinanceProvider prov, NumberFormat currency) {
    final incomeData = prov.dailyIncomeTrend;
    final expenseData = prov.dailyExpenseTrend;
    if (incomeData.isEmpty && expenseData.isEmpty) return _buildEmptyState();

    List<FlSpot> incomeSpots = incomeData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    List<FlSpot> expenseSpots = expenseData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return LineChart(
      key: const ValueKey('line'),
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300, width: 1)),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}