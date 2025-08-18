import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TransactionTile({super.key, required this.tx, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<FinanceProvider>();
    final cat = prov.categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => prov.categories.first);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final amountText = (tx.type == TxType.income ? '+' : '-') + currency.format(tx.amount);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(cat.icon)),
        title: Text(cat.name),
        subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(tx.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amountText, style: TextStyle(color: tx.type == TxType.income ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
            if (tx.note.isNotEmpty) Text(tx.note, style: const TextStyle(fontSize: 12)),
          ],
        ),
        onTap: onEdit,
        onLongPress: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Hapus transaksi?'),
              content: const Text('Tindakan ini tidak bisa dibatalkan.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
              ],
            ),
          );
          if (ok == true) onDelete();
        },
      ),
    );
  }
}
