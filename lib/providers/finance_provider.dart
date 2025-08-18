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
