import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/transaction_repository.dart';
import '../models/expense_transaction.dart';

const transactionCategories = [
  'Food & Dining',
  'Transportation',
  'Shopping',
  'Bills & Utilities',
  'Health',
  'Entertainment',
  'Salary',
  'Other',
];

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    required this.repository,
    this.transaction,
    super.key,
  });

  final TransactionRepository repository;
  final ExpenseTransaction? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _date;
  String? _category;
  TransactionType? _type;
  bool _saving = false;

  bool get _editing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );
    _date = transaction?.date ?? DateTime.now();
    _category = transaction?.category;
    _type = transaction?.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final type = _type;
    if (type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a transaction type')),
      );
      return;
    }

    final transaction = ExpenseTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category!,
      type: type,
      date: _date,
    );
    setState(() => _saving = true);
    try {
      if (_editing) {
        await widget.repository.update(transaction);
      } else {
        await widget.repository.insert(transaction);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit transaction' : 'Add transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Weekly groceries',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a title'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter a valid amount greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: transactionCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) => value == null ? 'Select a category' : null,
            ),
            const SizedBox(height: 22),
            Text(
              'Transaction type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.north_east_rounded),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.south_west_rounded),
                ),
              ],
              selected: _type == null ? {} : {_type!},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) => setState(
                () => _type = selection.isEmpty ? null : selection.first,
              ),
            ),
            if (_type == null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  'Select a transaction type',
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                'Date: ${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}/${_date.year}',
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_editing ? 'Save changes' : 'Save transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
