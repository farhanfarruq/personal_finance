import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import 'add_edit_transaction_screen.dart';
import 'categories_screen.dart';
import '../widgets/transaction_tile.dart';
import 'dashboard_screen.dart'; // Import halaman dasbor yang baru

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FinanceProvider>();
    // Perbaikan format mata uang agar menggunakan titik dan tanpa desimal
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keuangan • ${prov.monthLabel}'),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: prov.prevMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: prov.nextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          // Tombol baru untuk navigasi ke halaman Dasbor
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            tooltip: 'Lihat Dasbor',
            icon: const Icon(Icons.dashboard_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
            tooltip: 'Kategori',
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(),
            ),
          );
        },
        label: const Text('Tambah Transaksi'),
        icon: const Icon(Icons.add),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: prov.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Bagian Kartu Ringkasan ---
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
              'Saldo Bulan Ini',
              currency.format(prov.balance),
              Icons.account_balance_wallet_outlined,
              Colors.teal,
            ),
            const SizedBox(height: 24),

            // --- Bagian Grafik Batang yang Diperbarui ---
            const Text('Perbandingan Pemasukan & Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
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
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Pemasukan';
                              break;
                            case 1:
                              text = 'Pengeluaran';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: prov.income, color: Colors.green, width: 22, borderRadius: BorderRadius.circular(8))
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: prov.expense, color: Colors.red, width: 22, borderRadius: BorderRadius.circular(8))
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Bagian Transaksi Terbaru ---
            const Text('Transaksi Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (prov.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Belum ada transaksi bulan ini.\nYuk, mulai catat keuanganmu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ...prov.transactions.map((t) => TransactionTile(
                    tx: t,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionScreen(existing: t),
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

  // --- Widget _summaryCard yang sudah diperbaiki ---
  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 28,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            // Widget Expanded ini adalah kunci untuk memperbaiki error overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis, // Menambahkan elipsis jika teks masih terlalu panjang
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