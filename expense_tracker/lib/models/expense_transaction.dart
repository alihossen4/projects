enum TransactionType {
  income,
  expense;

  String get label => this == TransactionType.income ? 'Income' : 'Expense';

  String get databaseValue => name;
}

class ExpenseTransaction {
  const ExpenseTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  final int? id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.databaseValue,
      'date': date.toIso8601String(),
    };
  }
}
