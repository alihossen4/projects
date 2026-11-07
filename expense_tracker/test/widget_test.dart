import 'package:expense_tracker/data/transaction_repository.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTransactionRepository implements TransactionRepository {
  _MemoryTransactionRepository([List<ExpenseTransaction>? transactions])
    : transactions = transactions ?? [];

  final List<ExpenseTransaction> transactions;
  var _nextId = 1;

  @override
  Future<int> insert(ExpenseTransaction transaction) async {
    final id = _nextId++;
    transactions.add(_withId(transaction, id));
    return id;
  }

  @override
  Future<int> update(ExpenseTransaction transaction) async {
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index < 0) return 0;
    transactions[index] = transaction;
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    final initialLength = transactions.length;
    transactions.removeWhere((transaction) => transaction.id == id);
    return initialLength - transactions.length;
  }

  @override
  Future<List<ExpenseTransaction>> getAll() async {
    final result = [...transactions];
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  ExpenseTransaction _withId(ExpenseTransaction transaction, int id) {
    return ExpenseTransaction(
      id: id,
      title: transaction.title,
      amount: transaction.amount,
      category: transaction.category,
      type: transaction.type,
      date: transaction.date,
    );
  }
}

void main() {
  testWidgets(
    'dashboard updates totals when a transaction is edited and deleted',
    (tester) async {
      final repository = _MemoryTransactionRepository([
        ExpenseTransaction(
          id: 1,
          title: 'Salary',
          amount: 100,
          category: 'Salary',
          type: TransactionType.income,
          date: DateTime(2026, 3, 10),
        ),
        ExpenseTransaction(
          id: 2,
          title: 'Lunch',
          amount: 30,
          category: 'Food & Dining',
          type: TransactionType.expense,
          date: DateTime(2026, 3, 11),
        ),
      ]);

      await tester.pumpWidget(MyApp(repository: repository));
      await tester.pumpAndSettle();
      expect(find.text('\$70.00'), findsOneWidget);
      expect(find.text('Total income'), findsOneWidget);
      expect(find.text('Total expense'), findsOneWidget);

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();
      expect(find.text('Transaction details'), findsOneWidget);
      await tester.tap(find.text('Edit transaction'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Coffee');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('\$70.00'), findsOneWidget);

      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsNothing);
      expect(find.text('\$100.00'), findsWidgets);
      expect(repository.transactions, hasLength(1));
    },
  );

  testWidgets(
    'new transaction form validates required data and saves a transaction',
    (tester) async {
      final repository = _MemoryTransactionRepository();
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a title'), findsOneWidget);
      expect(
        find.text('Enter a valid amount greater than zero'),
        findsOneWidget,
      );
      expect(find.text('Select a category'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Freelance');
      await tester.enterText(find.byType(TextFormField).last, '250');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salary').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(SnackBar, 'Select a transaction type'),
        findsOneWidget,
      );
      await tester.tap(find.text('Income').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();

      expect(repository.transactions, hasLength(1));
      expect(repository.transactions.single.title, 'Freelance');
      expect(repository.transactions.single.amount, 250);
      expect(repository.transactions.single.type, TransactionType.income);
      expect(find.text('\$250.00'), findsWidgets);
    },
  );

  testWidgets(
    'dashboard refreshes after deleting from the full list and going back',
    (tester) async {
      final repository = _MemoryTransactionRepository([
        ExpenseTransaction(
          id: 1,
          title: 'Rent',
          amount: 80,
          category: 'Bills & Utilities',
          type: TransactionType.expense,
          date: DateTime(2026, 3, 10),
        ),
      ]);

      await tester.pumpWidget(MyApp(repository: repository));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('All transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rent'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Current balance'), findsOneWidget);
      expect(find.text('\$0.00'), findsWidgets);
    },
  );
}
