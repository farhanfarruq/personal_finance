import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/db_service.dart';

class FinanceProvider extends ChangeNotifier {
  final _db = DBService();
  DateTime currentMonth = DateTime.now();
  List<TransactionModel> transactions = [];
  List<CategoryModel> categories = [];
  double income = 0;
  double expense = 0;

  String get monthLabel => DateFormat('MMMM yyyy').format(currentMonth);
  double get balance => income - expense;

  Future<void> init() async {
    categories = await _db.getCategories();
    await refresh();
  }

  Future<void> refresh() async {
    transactions = await _db.getTransactions(month: currentMonth);
    income = await _db.sumByType(TxType.income, month: currentMonth);
    expense = await _db.sumByType(TxType.expense, month: currentMonth);
    notifyListeners();
  }

  void nextMonth() {
    currentMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 1);
    refresh();
  }

  void prevMonth() {
    currentMonth =
        DateTime(currentMonth.year, currentMonth.month - 1, 1);
    refresh();
  }

  Future<void> addTx(TransactionModel t) async {
    await _db.addTransaction(t);
    await refresh();
  }

  Future<void> updateTx(TransactionModel t) async {
    await _db.updateTransaction(t);
    await refresh();
  }

  Future<void> deleteTx(int id) async {
    await _db.deleteTransaction(id);
    await refresh();
  }

  Future<void> addCategory(CategoryModel c) async {
    await _db.addCategory(c);
    categories = await _db.getCategories();
    notifyListeners();
  }
}

Map<CategoryModel, double> get expenseByCategory {
  final Map<CategoryModel, double> data = {};
  final expenseTxs = transactions.where((tx) => tx.type == TxType.expense);

  if (expenseTxs.isEmpty) return data;

  for (var tx in expenseTxs) {
    // Menambahkan orElse untuk mencegah error jika kategori tidak ditemukan
    final category = categories.firstWhere(
      (cat) => cat.id == tx.categoryId,
      orElse: () => CategoryModel(id: 0, name: 'Lainnya', icon: '❓'),
    );
    data[category] = (data[category] ?? 0) + tx.amount;
  }
  return data;
}

  // Getter baru untuk tren pengeluaran harian
  Map<int, double> get dailyExpenseTrend {
    final Map<int, double> data = {};
    final expenseTxs =
        transactions.where((tx) => tx.type == TxType.expense);
    for (var tx in expenseTxs) {
      data[tx.date.day] = (data[tx.date.day] ?? 0) + tx.amount;
    }
    return data;
  }
  
  // Getter baru untuk tren pemasukan harian
  Map<int, double> get dailyIncomeTrend {
    final Map<int, double> data = {};
    final incomeTxs = transactions.where((tx) => tx.type == TxType.income);
    for (var tx in incomeTxs) {
      data[tx.date.day] = (data[tx.date.day] ?? 0) + tx.amount;
    }
    return data;
  }
}