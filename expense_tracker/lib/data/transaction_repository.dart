import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/expense_transaction.dart';

abstract interface class TransactionRepository {
  Future<List<ExpenseTransaction>> getAll();
  Future<int> insert(ExpenseTransaction transaction);
  Future<int> update(ExpenseTransaction transaction);
  Future<int> delete(int id);
}

class SqfliteTransactionRepository implements TransactionRepository {
  SqfliteTransactionRepository({this.databasePath});

  final String? databasePath;
  Future<Database>? _database;

  Future<Database> get _db async {
    return _database ??= _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final resolvedDatabasePath =
        databasePath ??
        (kIsWeb
            ? 'expense_tracker.db'
            : path.join(await getDatabasesPath(), 'expense_tracker.db'));
    return openDatabase(
      resolvedDatabasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<ExpenseTransaction>> getAll() async {
    final rows = await (await _db).query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  @override
  Future<int> insert(ExpenseTransaction transaction) async {
    return (await _db).insert('transactions', transaction.toMap());
  }

  @override
  Future<int> update(ExpenseTransaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ArgumentError.value(
        id,
        'transaction.id',
        'An id is required to update a transaction.',
      );
    }
    return (await _db).update(
      'transactions',
      transaction.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> delete(int id) async {
    return (await _db).delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
