import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _nameCtrl = TextEditingController();
  final _iconCtrl = TextEditingController(text: '✨');

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...prov.categories.map((c) => ListTile(
                leading: Text(c.icon, style: const TextStyle(fontSize: 20)),
                title: Text(c.name),
              )),
          const Divider(height: 32),
          const Text('Tambah Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _iconCtrl,
            decoration: const InputDecoration(labelText: 'Ikon (emoji)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              if (_nameCtrl.text.trim().isEmpty) return;
              await prov.addCategory(CategoryModel(name: _nameCtrl.text.trim(), icon: _iconCtrl.text.trim()));
              _nameCtrl.clear();
              _iconCtrl.text = '✨';
            },
            child: const Text('Tambah'),
          )
        ],
      ),
    );
  }
}
