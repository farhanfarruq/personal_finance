import 'package:flutter/foundation.dart';

enum TxType { income, expense }

class TransactionModel {
  final int? id;
  final DateTime date;
  final double amount;
  final TxType type;
  final int categoryId;
  final String note;

  TransactionModel({
    this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'type': type.name,
        'category_id': categoryId,
        'note': note,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      type: (map['type'] == 'income') ? TxType.income : TxType.expense,
      categoryId: map['category_id'] as int,
      note: (map['note'] ?? '') as String,
    );
  }
}
