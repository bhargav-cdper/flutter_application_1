import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// Separate Bank Detail Screen Class with Table View
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
  String _searchField = 'All';
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

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
      bool matchesSearch = _searchQuery.isEmpty || _matchesSearchField(transaction);
      bool matchesType = _searchField == 'Type' ? 
          (_filterType == 'All' ||
           (_filterType == 'Credit' && transaction.credit > 0) ||
           (_filterType == 'Debit' && transaction.debit > 0)) : true;
      bool matchesDateRange = _matchesDateRange(transaction);

      return matchesSearch && matchesType && matchesDateRange;
    }).toList();
  }

  bool _matchesSearchField(BankTransaction transaction) {
    String query = _searchQuery.toLowerCase();
    
    switch (_searchField) {
      case 'Description':
        return transaction.description.toLowerCase().contains(query);
      case 'Party':
        return transaction.party.toLowerCase().contains(query);
      case 'Date':
        return true;
      case 'Salary/Loan':
        return transaction.salaryLoanMonth.toLowerCase().contains(query);
      case 'Type':
        return true;
      case 'All':
      default:
        return transaction.description.toLowerCase().contains(query) ||
               transaction.party.toLowerCase().contains(query) ||
               transaction.date.toLowerCase().contains(query) ||
               transaction.salaryLoanMonth.toLowerCase().contains(query);
    }
  }

  bool _matchesDateRange(BankTransaction transaction) {
    if (_startDate == null && _endDate == null) return true;
    
    DateTime transactionDate = transaction.dateAsDateTime;
    
    if (_startDate != null && transactionDate.isBefore(_startDate!)) {
      return false;
    }
    
    if (_endDate != null && transactionDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
      return false;
    }
    
    return true;
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

  void _onSearchFieldChanged(String field) {
    setState(() {
      _searchField = field;
      _applyFilters();
    });
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _applyFilters();
      });
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _applyFilters();
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _applyFilters();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchField = 'All';
      _filterType = 'All';
      _startDate = null;
      _endDate = null;
      _searchController.clear();
      _applyFilters();
    });
  }

  String _getSearchHint() {
    switch (_searchField) {
      case 'Description':
        return 'Search descriptions...';
      case 'Party':
        return 'Search parties...';
      case 'Date':
        return 'Select date range below';
      case 'Salary/Loan':
        return 'Search salary/loan...';
      case 'Type':
        return 'Select transaction type';
      case 'All':
      default:
        return 'Search all fields...';
    }
  }

  IconData _getSearchIcon() {
    switch (_searchField) {
      case 'Description':
        return Icons.description;
      case 'Party':
        return Icons.person;
      case 'Date':
        return Icons.calendar_today;
      case 'Salary/Loan':
        return Icons.work;
      case 'Type':
        return Icons.category;
      case 'All':
      default:
        return Icons.search;
    }
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty || 
           (_searchField == 'Type' && _filterType != 'All') || 
           _searchField != 'All' || 
           _startDate != null;
  }

  String _getActiveFiltersText() {
    List<String> activeFilters = [];
    
    if (_searchField != 'All') {
      if (_searchField == 'Type' && _filterType != 'All') {
        activeFilters.add('$_searchField: $_filterType');
      } else {
        activeFilters.add(_searchField);
      }
    }
    if (_searchQuery.isNotEmpty) {
      activeFilters.add('"${_searchQuery.length > 8 ? '${_searchQuery.substring(0, 8)}...' : _searchQuery}"');
    }
    if (_startDate != null) {
      activeFilters.add('Date Range');
    }
    
    return activeFilters.join(' • ');
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

  Future<void> _editTransaction(BankTransaction transaction) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => _EditTransactionScreen(
          transaction: transaction,
          bankName: widget.bankName,
        ),
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
                // Compact Balance Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _currentBalance >= 0 
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Balance: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₹${_currentBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_transactions.length} transactions',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      // Search Field Selection
                      Row(
                        children: [
                          const Text(
                            'Search: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['All', 'Description', 'Party', 'Date', 'Type', 'Salary/Loan'].map((field) {
                                  final isSelected = _searchField == field;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(
                                        field,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) => _onSearchFieldChanged(field),
                                      backgroundColor: Colors.white,
                                      selectedColor: Colors.green.shade100,
                                      checkmarkColor: Colors.green.shade700,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Dynamic Search Input
                      if (_searchField == 'Type') ...[
                        DropdownButtonFormField<String>(
                          initialValue: _filterType,
                          decoration: InputDecoration(
                            hintText: 'Select transaction type',
                            prefixIcon: Icon(Icons.category, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Transactions')),
                            DropdownMenuItem(
                              value: 'Credit',
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle, color: Colors.green, size: 18),
                                  SizedBox(width: 8),
                                  Text('Credit (Income)'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Debit',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle, color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('Debit (Expense)'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) => _onFilterChanged(value!),
                        ),
                      ] else if (_searchField == 'Date') ...[
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectFromDate,
                                    icon: const Icon(Icons.calendar_today, size: 16),
                                    label: Text(
                                      _startDate != null 
                                          ? 'From: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                          : 'Select From Date',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _startDate != null ? Colors.blue.shade50 : Colors.white,
                                      foregroundColor: _startDate != null ? Colors.blue.shade700 : Colors.grey.shade700,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectToDate,
                                    icon: const Icon(Icons.calendar_today, size: 16),
                                    label: Text(
                                      _endDate != null 
                                          ? 'To: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                          : 'Select To Date',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _endDate != null ? Colors.blue.shade50 : Colors.white,
                                      foregroundColor: _endDate != null ? Colors.blue.shade700 : Colors.grey.shade700,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_startDate != null || _endDate != null) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _clearDateRange,
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Clear Date Range', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
                        TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: _getSearchHint(),
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: Icon(
                              _getSearchIcon(),
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      
                      // Results and Clear All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_hasActiveFilters())
                            TextButton.icon(
                              onPressed: _clearAllFilters,
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Clear All', style: TextStyle(fontSize: 11)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            )
                          else
                            const SizedBox(),
                          
                          if (_transactions.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                'Results: ${_filteredTransactions.length} of ${_transactions.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      if (_hasActiveFilters())
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              _getActiveFiltersText(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Transactions Table
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _transactions.isEmpty ? Icons.receipt_long : Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _transactions.isEmpty 
                                    ? 'No transactions yet' 
                                    : 'No transactions match your filters',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _transactions.isEmpty 
                                    ? 'Tap the + button to add a transaction'
                                    : 'Try adjusting your search or filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
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
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Date',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Description',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Credit',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  numeric: true,
                                ),
                                DataColumn(
                                  label: Text(
                                    'Debit',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  numeric: true,
                                ),
                                DataColumn(
                                  label: Text(
                                    'Balance',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  numeric: true,
                                ),
                                DataColumn(
                                  label: Text(
                                    'Party',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Salary/Loan',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              rows: _filteredTransactions.map((transaction) {
                                final isCredit = transaction.credit > 0;
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        transaction.date,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 150),
                                        child: Text(
                                          transaction.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        transaction.credit > 0 
                                            ? '₹${transaction.credit.toStringAsFixed(2)}'
                                            : '-',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: transaction.credit > 0 ? Colors.green : Colors.grey,
                                          fontWeight: transaction.credit > 0 ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        transaction.debit > 0 
                                            ? '₹${transaction.debit.toStringAsFixed(2)}'
                                            : '-',
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
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 120),
                                        child: Text(
                                          transaction.salaryLoanMonth.isEmpty ? '-' : transaction.salaryLoanMonth,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              _editTransaction(transaction);
                                              break;
                                            case 'delete':
                                              _deleteTransaction(transaction);
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 16, color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, size: 16, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
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

// Edit Transaction Screen (Inline)
class _EditTransactionScreen extends StatefulWidget {
  final BankTransaction transaction;
  final String bankName;

  const _EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.bankName,
  });

  @override
  State<_EditTransactionScreen> createState() => __EditTransactionScreenState();
}

class __EditTransactionScreenState extends State<_EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _creditController = TextEditingController();
  final _debitController = TextEditingController();
  final _salaryLoanMonthController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedParty;
  List<String> _parties = [];
  bool _isCredit = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    _parties = await DataService.getParty();
    
    _descriptionController.text = widget.transaction.description;
    _selectedDate = widget.transaction.dateAsDateTime;
    _selectedParty = widget.transaction.party.isNotEmpty ? widget.transaction.party : null;
    _salaryLoanMonthController.text = widget.transaction.salaryLoanMonth;
    
    if (widget.transaction.credit > 0) {
      _isCredit = true;
      _creditController.text = widget.transaction.credit.toString();
    } else {
      _isCredit = false;
      _debitController.text = widget.transaction.debit.toString();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _creditController.dispose();
    _debitController.dispose();
    _salaryLoanMonthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (DateTime selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final creditAmount = double.tryParse(_creditController.text) ?? 0.0;
    final debitAmount = double.tryParse(_debitController.text) ?? 0.0;

    if (creditAmount > 0 && debitAmount > 0) {
      _showSnackBar('Please enter either credit OR debit amount, not both');
      return;
    }

    if (creditAmount == 0 && debitAmount == 0) {
      _showSnackBar('Please enter either credit or debit amount');
      return;
    }

    try {
      bool deleteSuccess = await DataService.deleteBankTransaction(widget.transaction.id);
      
      if (deleteSuccess) {
        final updatedTransaction = BankTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: _formatDate(_selectedDate),
          description: _descriptionController.text.trim(),
          credit: creditAmount,
          debit: debitAmount,
          netBalance: 0.0,
          party: _selectedParty ?? '',
          salaryLoanMonth: _salaryLoanMonthController.text.trim(),
          bankName: widget.bankName,
        );

        bool addSuccess = await DataService.addBankTransaction(updatedTransaction);
        
        if (addSuccess) {
          _showSnackBar('Transaction updated successfully');
          Navigator.pop(context, true);
        } else {
          _showSnackBar('Failed to update transaction');
        }
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        title: const Text('Edit Transaction'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Editing transaction for:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.bankName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'Enter transaction description',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCredit = true;
                            _debitController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isCredit ? Colors.green : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'CREDIT (+)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isCredit ? Colors.white : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCredit = false;
                            _creditController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isCredit ? Colors.red : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'DEBIT (-)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isCredit ? Colors.white : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _isCredit ? _creditController : _debitController,
                decoration: InputDecoration(
                  labelText: _isCredit ? 'Credit Amount *' : 'Debit Amount *',
                  border: const OutlineInputBorder(),
                  hintText: 'Enter amount',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedParty,
                decoration: const InputDecoration(
                  labelText: 'Party',
                  border: OutlineInputBorder(),
                ),
                items: _parties.map((String party) {
                  return DropdownMenuItem<String>(
                    value: party,
                    child: Text(party),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedParty = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _salaryLoanMonthController,
                decoration: const InputDecoration(
                  labelText: 'Salary/Loan Month',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., January 2024',
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'UPDATE TRANSACTION',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}