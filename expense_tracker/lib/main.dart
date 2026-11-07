import 'package:flutter/material.dart';

import 'data/database_initializer.dart';
import 'data/transaction_repository.dart';
import 'models/expense_transaction.dart';
import 'screens/transaction_detail_screen.dart';
import 'screens/transaction_form_screen.dart';
import 'widgets/transaction_tile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseFactory();
  runApp(MyApp(repository: SqfliteTransactionRepository()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final TransactionRepository? repository;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF3D6F64);
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFF7F8F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F5),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: DashboardScreen(
        repository: repository ?? SqfliteTransactionRepository(),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.repository, super.key});

  final TransactionRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ExpenseTransaction> _transactions = [];
  Object? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final transactions = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<void> _addTransaction() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(repository: widget.repository),
      ),
    );
    if (saved == true) await _loadTransactions();
  }

  Future<void> _openDetails(ExpenseTransaction transaction) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(
          transaction: transaction,
          repository: widget.repository,
        ),
      ),
    );
    if (changed == true) await _loadTransactions();
  }

  Future<void> _openAllTransactions() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AllTransactionsScreen(repository: widget.repository),
      ),
    );
    if (changed == true) await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final income = _transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final expenses = _transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final recent = _transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'All transactions',
            onPressed: _openAllTransactions,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: _loading && _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _LoadError(error: _loadError!, onRetry: _loadTransactions)
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
                children: [
                  Text(
                    'Your finances, at a glance',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 18),
                  _BalanceCard(balance: income - expenses),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total income',
                          amount: income,
                          icon: Icons.south_west_rounded,
                          color: const Color(0xFF168A65),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total expense',
                          amount: expenses,
                          icon: Icons.north_east_rounded,
                          color: const Color(0xFFE15D5D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent transactions',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: _openAllTransactions,
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (recent.isEmpty)
                    const _EmptyTransactions()
                  else
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.builder(
                        itemCount: recent.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final transaction = recent[index];
                          return TransactionTile(
                            transaction: transaction,
                            onTap: () => _openDetails(transaction),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add transaction'),
      ),
    );
  }
}

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({required this.repository, super.key});

  final TransactionRepository repository;

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  List<ExpenseTransaction> _transactions = [];
  Object? _error;
  bool _loading = true;
  bool _changed = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final transactions = await widget.repository.getAll();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  Future<void> _openDetails(ExpenseTransaction transaction) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(
          transaction: transaction,
          repository: widget.repository,
        ),
      ),
    );
    if (changed == true) {
      _changed = true;
      await _load();
    }
  }

  void _close() => _closeAfterSystemBack();

  void _closeAfterSystemBack() {
    if (_allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, _changed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeAfterSystemBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All transactions'),
          leading: BackButton(onPressed: _close),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _LoadError(error: _error!, onRetry: _load)
            : _transactions.isEmpty
            ? const Center(child: _EmptyTransactions())
            : ListView.builder(
                itemCount: _transactions.length,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return TransactionTile(
                    transaction: transaction,
                    onTap: () => _openDetails(transaction),
                  );
                },
              ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final balanceColor = balance < 0
        ? const Color(0xFFFFD1CE)
        : const Color(0xFFBDE8D6);
    return Card(
      color: const Color(0xFF244D45),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current balance',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: balanceColor,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'No transactions yet',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first transaction to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Could not load transactions',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
