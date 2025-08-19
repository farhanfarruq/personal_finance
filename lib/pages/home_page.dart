import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import 'add_edit_transaction_page.dart';
import 'categories_page.dart';
import '../widgets/transaction_tile.dart';
import '../models/transaction_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keuangan • ${prov.monthLabel}'),
        actions: [
          IconButton(
            onPressed: prov.prevMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: prov.nextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesPage()),
              );
            },
            icon: const Icon(Icons.category),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTransactionPage(),
            ),
          );
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: prov.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Pemasukan',
                    currency.format(prov.income),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    'Pengeluaran',
                    currency.format(prov.expense),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _summaryCard(
              'Saldo',
              currency.format(prov.balance),
              Icons.account_balance_wallet,
              Colors.teal,
            ),
            const SizedBox(height: 16),

            // Mini Bar Chart income vs expense
// ... (kode lainnya)

// Ganti widget BarChart yang ada dengan kode berikut:
SizedBox(
  height: 200,
  child: BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final style = TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = Text('Pemasukan', style: style);
                  break;
                case 1:
                  text = Text('Pengeluaran', style: style);
                  break;
                default:
                  text = Text('', style: style);
                  break;
              }
              return SideTitleWidget(axisSide: meta.axisSide, child: text);
            },
            reservedSize: 30,
          ),
        ),
      ),
      gridData: FlGridData(show: false),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: prov.income,
              color: Colors.green,
              width: 22,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: prov.expense,
              color: Colors.red,
              width: 22,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ],
    ),
  ),
),

// ... (kode lainnya)

            const SizedBox(height: 16),
            const Text('Transaksi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            if (prov.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Belum ada transaksi bulan ini.')),
              )
            else
              ...prov.transactions.map((t) => TransactionTile(
                    tx: t,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionPage(existing: t),
                        ),
                      );
                    },
                    onDelete: () => prov.deleteTx(t.id!),
                  )),
          ],
        ),
      ),
    );
  }

// farhanfarruq/personal_finance/personal_finance-9dc4a3471684685b48bafc19424765a788b29d69/lib/pages/home_page.dart
Widget _summaryCard(String title, String value, IconData icon, Color color) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          // Tambahkan Expanded di sini untuk mengatasi overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // Opsi untuk menampilkan elipsis (...) jika teks masih terlalu panjang
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}