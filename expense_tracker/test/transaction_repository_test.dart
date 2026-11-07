import 'package:expense_tracker/data/database_initializer.dart';
import 'package:expense_tracker/data/transaction_repository.dart';
import 'package:expense_tracker/models/expense_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initialized SQLite factory supports transaction CRUD', () async {
    await initializeDatabaseFactory();
    final repository = SqfliteTransactionRepository(
      databasePath: inMemoryDatabasePath,
    );
    final transaction = ExpenseTransaction(
      title: 'Coffee',
      amount: 4.5,
      category: 'Food & Dining',
      type: TransactionType.expense,
      date: DateTime(2026, 11, 7),
    );

    final id = await repository.insert(transaction);
    final inserted = await repository.getAll();
    expect(inserted, hasLength(1));
    expect(inserted.single.id, id);
    expect(inserted.single.title, 'Coffee');

    final updated = ExpenseTransaction(
      id: id,
      title: 'Coffee and pastry',
      amount: 8,
      category: transaction.category,
      type: transaction.type,
      date: transaction.date,
    );
    expect(await repository.update(updated), 1);
    expect((await repository.getAll()).single.amount, 8);

    expect(await repository.delete(id), 1);
    expect(await repository.getAll(), isEmpty);
  });
}
