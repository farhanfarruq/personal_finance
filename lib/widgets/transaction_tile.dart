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
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final amountText = (tx.type == TxType.income ? '+' : '-') + currency.format(tx.amount);

return Card(
  elevation: 1,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      child: Text(
        cat.icon,
        style: const TextStyle(fontSize: 24),
      ),
      radius: 25,
    ),
    title: Text(
      cat.name,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(tx.date),
      style: TextStyle(color: Colors.grey[600]),
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amountText,
          style: TextStyle(
            color: tx.type == TxType.income ? Colors.green.shade600 : Colors.red.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (tx.note.isNotEmpty)
          Expanded(
            child: Text(
              tx.note,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
