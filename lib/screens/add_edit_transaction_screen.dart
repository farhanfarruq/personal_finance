import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;
  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  double _amount = 0;
  TxType _type = TxType.expense;
  int? _categoryId;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _date = e.date;
      _amount = e.amount;
      _type = e.type;
      _categoryId = e.categoryId;
      _noteCtrl.text = e.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Tambah Transaksi' : 'Ubah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type
              SegmentedButton<TxType>(
                segments: const [
                  ButtonSegment(value: TxType.expense, label: Text('Pengeluaran'), icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(value: TxType.income, label: Text('Pemasukan'), icon: Icon(Icons.arrow_downward)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                initialValue: widget.existing != null ? widget.existing!.amount.toString() : '',
                decoration: InputDecoration(labelText: 'Nominal (${currency.currencySymbol.trim()})', border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Nominal wajib' : null,
                onSaved: (v) => _amount = double.tryParse(v!.replaceAll(',', '.')) ?? 0,
              ),
              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<int>(
                value: _categoryId,
                items: prov.categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon} ${c.name}')))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Pilih kategori' : null,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal'),
                subtitle: Text(DateFormat('dd MMMM yyyy', 'id_ID').format(_date)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('id', 'ID'),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Note
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final tx = TransactionModel(
                      id: widget.existing?.id,
                      date: _date,
                      amount: _amount,
                      type: _type,
                      categoryId: _categoryId!,
                      note: _noteCtrl.text,
                    );
                    if (widget.existing == null) {
                      await context.read<FinanceProvider>().addTx(tx);
                    } else {
                      await context.read<FinanceProvider>().updateTx(tx);
                    }
                    if (mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(widget.existing == null ? 'Simpan' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}