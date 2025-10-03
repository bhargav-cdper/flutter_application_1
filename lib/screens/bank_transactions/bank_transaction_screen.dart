import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/bank_transaction.dart';
import 'add_bank_transaction_screen.dart';

class BankTransactionScreen extends StatefulWidget {
  const BankTransactionScreen({super.key});

  @override
  State<BankTransactionScreen> createState() => _BankTransactionScreenState();
}

class _BankTransactionScreenState extends State<BankTransactionScreen> {
  List<String> _bankOptions = [];
  List<BankTransaction> _allTransactions = [];
  final Map<String, double> _bankBalances = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadBankOptions();
    await _loadTransactions();
    _calculateBalances();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBankOptions() async {
    _bankOptions = await DataService.getCashBank();
    _bankOptions = _bankOptions.where((option) => 
      option.toLowerCase().contains('bank') || 
      option.toLowerCase().contains('wallet')).toList();
  }

  Future<void> _loadTransactions() async {
    _allTransactions = await DataService.getBankTransactions();
  }

  void _calculateBalances() {
    _bankBalances.clear();
    
    for (String bank in _bankOptions) {
      _bankBalances[bank] = 0.0;
    }
    
    for (String bank in _bankOptions) {
      List<BankTransaction> bankTransactions = _allTransactions
          .where((transaction) => transaction.bankName == bank)
          .toList();
      
      bankTransactions.sort((a, b) => 
        a.dateAsDateTime.compareTo(b.dateAsDateTime));
      
      double balance = 0.0;
      for (var transaction in bankTransactions) {
        balance += transaction.credit - transaction.debit;
      }
      
      _bankBalances[bank] = balance;
    }
  }

  Future<void> _navigateToBankDetail(String bankName) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BankDetailScreen(bankName: bankName),
      ),
    );

    if (result == true) {
      await _loadTransactions();
      _calculateBalances();
      setState(() {});
    }
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) return Colors.green.shade700;
    if (balance < 0) return Colors.red.shade700;
    return Colors.grey.shade600;
  }

  IconData _getBankIcon(String bankName) {
    String lowerBank = bankName.toLowerCase();
    if (lowerBank.contains('wallet')) return Icons.account_balance_wallet;
    if (lowerBank.contains('cash')) return Icons.money;
    return Icons.account_balance;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _bankOptions.isEmpty
          ? const Center(
              child: Text(
                'No bank accounts found\nAdd banks in Settings first',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bankOptions.length,
                    itemBuilder: (context, index) {
                      final bankName = _bankOptions[index];
                      final balance = _bankBalances[bankName] ?? 0.0;
                      final balanceColor = _getBalanceColor(balance);
                      final bankIcon = _getBankIcon(bankName);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              bankIcon,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            bankName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Current Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: balanceColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToBankDetail(bankName),
                        ),
                      );
                    },
                  ),
                ),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      Text(
                        'Total Accounts: ${_bankOptions.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Balance: ₹${_bankBalances.values.fold(0.0, (sum, balance) => sum + balance).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getBalanceColor(
                            _bankBalances.values.fold(0.0, (sum, balance) => sum + balance)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// Bank Detail Screen with Table View
class BankDetailScreen extends StatefulWidget {
  final String bankName;
  
  const BankDetailScreen({
    super.key,
    required this.bankName,
  });

  @override
  State<BankDetailScreen> createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  List<BankTransaction> _transactions = [];
  List<BankTransaction> _filteredTransactions = [];
  double _currentBalance = 0.0;
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    List<BankTransaction> allTransactions = await DataService.getBankTransactions();
    
    _transactions = allTransactions
        .where((transaction) => transaction.bankName == widget.bankName)
        .toList();
    
    _transactions.sort((a, b) => b.dateAsDateTime.compareTo(a.dateAsDateTime));
    
    _calculateBalance();
    _applyFilters();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _calculateBalance() {
    List<BankTransaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => a.dateAsDateTime.compareTo(b.dateAsDateTime));
    
    double runningBalance = 0.0;
    for (var transaction in sortedTransactions) {
      runningBalance += transaction.credit - transaction.debit;
      transaction.netBalance = runningBalance;
    }
    
    _currentBalance = runningBalance;
  }

  void _applyFilters() {
    _filteredTransactions = _transactions.where((transaction) {
      bool matchesSearch = _searchQuery.isEmpty || 
          transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transaction.party.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesType = _filterType == 'All' ||
          (_filterType == 'Credit' && transaction.credit > 0) ||
          (_filterType == 'Debit' && transaction.debit > 0);

      return matchesSearch && matchesType;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterType = filter;
      _applyFilters();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _filterType = 'All';
      _searchController.clear();
      _applyFilters();
    });
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBankTransactionScreen(bankName: widget.bankName),
      ),
    );

    if (result == true) {
      await _loadTransactions();
    }
  }

  Future<void> _deleteTransaction(BankTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?\n\n"${transaction.description}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bool success = await DataService.deleteBankTransaction(transaction.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
        await _loadTransactions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bankName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _navigateToAddTransaction,
            icon: const Icon(Icons.add),
            tooltip: 'Add Transaction',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Balance Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _currentBalance >= 0 
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_currentBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_transactions.length} transaction(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add Transaction Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _navigateToAddTransaction,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Transaction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search transactions...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _filterType,
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All')),
                              DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                              DropdownMenuItem(value: 'Debit', child: Text('Debit')),
                            ],
                            onChanged: (value) => _onFilterChanged(value!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: _clearAllFilters,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Filters'),
                          ),
                          Text(
                            'Showing ${_filteredTransactions.length} of ${_transactions.length}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transactions Table
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No transactions found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                              columns: const [
                                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                DataColumn(label: Text('Debit', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                DataColumn(label: Text('Party', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _filteredTransactions.map((transaction) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(transaction.date, style: const TextStyle(fontSize: 12))),
                                    DataCell(
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 150),
                                        child: Text(
                                          transaction.description,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        transaction.credit > 0 ? '₹${transaction.credit.toStringAsFixed(2)}' : '-',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: transaction.credit > 0 ? Colors.green : Colors.grey,
                                          fontWeight: transaction.credit > 0 ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        transaction.debit > 0 ? '₹${transaction.debit.toStringAsFixed(2)}' : '-',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: transaction.debit > 0 ? Colors.red : Colors.grey,
                                          fontWeight: transaction.debit > 0 ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${transaction.netBalance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: transaction.netBalance >= 0 ? Colors.blue : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 120),
                                        child: Text(
                                          transaction.party.isEmpty ? '-' : transaction.party,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () => _deleteTransaction(transaction),
                                        tooltip: 'Delete Transaction',
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        backgroundColor: Colors.blue,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}