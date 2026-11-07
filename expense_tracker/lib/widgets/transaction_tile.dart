import 'package:flutter/material.dart';

import '../models/expense_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.onTap,
    super.key,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF168A65) : const Color(0xFFE15D5D);
    final date = transaction.date;
    final formattedDate = '${_month(date.month)} ${date.day}, ${date.year}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        child: Icon(
          isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
        ),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${transaction.category} · $formattedDate'),
      trailing: Text(
        '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
