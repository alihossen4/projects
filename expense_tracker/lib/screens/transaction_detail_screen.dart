import 'package:flutter/material.dart';

import '../data/transaction_repository.dart';
import '../models/expense_transaction.dart';
import 'transaction_form_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    required this.transaction,
    required this.repository,
    super.key,
  });

  final ExpenseTransaction transaction;
  final TransactionRepository repository;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late final ExpenseTransaction _transaction = widget.transaction;
  bool _working = false;

  Future<void> _edit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(
          repository: widget.repository,
          transaction: _transaction,
        ),
      ),
    );
    if (updated == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('“${_transaction.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _working = true);
    try {
      final id = _transaction.id;
      if (id == null) {
        throw StateError('Cannot delete a transaction without an id.');
      }
      await widget.repository.delete(id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _working = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete transaction: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF168A65) : const Color(0xFFE15D5D);
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _transaction.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${isIncome ? '+' : '-'}\$${_transaction.amount.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _DetailRow(label: 'Category', value: _transaction.category),
          _DetailRow(label: 'Type', value: _transaction.type.label),
          _DetailRow(
            label: 'Date',
            value:
                '${_transaction.date.month.toString().padLeft(2, '0')}/${_transaction.date.day.toString().padLeft(2, '0')}/${_transaction.date.year}',
          ),
          if (_working) const LinearProgressIndicator(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _working ? null : _edit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit transaction'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _working ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete transaction'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
