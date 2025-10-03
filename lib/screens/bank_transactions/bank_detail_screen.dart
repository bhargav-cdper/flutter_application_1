import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/bank_transaction.dart';
import 'add_bank_transaction_screen.dart';

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
  double _currentBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    List<BankTransaction> allTransactions = await DataService.getBankTransactions();
    
    // Filter transactions for this bank
    _transactions = allTransactions
        .where((transaction) => transaction.bankName == widget.bankName)
        .toList();
    
    // Sort by date (newest first for display)
    _transactions.sort((a, b) => b.dateAsDateTime.compareTo(a.dateAsDateTime));
    
    _calculateBalance();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _calculateBalance() {
    // Sort by date for balance calculation (oldest first)
    List<BankTransaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => a.dateAsDateTime.compareTo(b.dateAsDateTime));
    
    // Calculate running balance
    double runningBalance = 0.0;
    for (var transaction in sortedTransactions) {
      runningBalance += transaction.credit - transaction.debit;
      transaction.netBalance = runningBalance;
    }
    
    _currentBalance = runningBalance;
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        // FIXED: Changed 'selectedBank' to 'bankName' to match the constructor parameter
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _currentBalance >= 0 
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                    label: const Text(
                      'Add New Transaction',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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

                // Transactions List
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add New Transaction" to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            final isCredit = transaction.credit > 0;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            transaction.description,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isCredit ? Colors.green : Colors.red,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isCredit 
                                              ? '+₹${transaction.credit.toStringAsFixed(2)}'
                                              : '-₹${transaction.debit.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _deleteTransaction(transaction),
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red.shade400,
                                          tooltip: 'Delete Transaction',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, 
                                             size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          transaction.date,
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(width: 16),
                                        if (transaction.party.isNotEmpty) ...[
                                          Icon(Icons.person, 
                                               size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            transaction.party,
                                            style: TextStyle(color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ],
                                    ),
                                    
                                    if (transaction.salaryLoanMonth.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.work, 
                                               size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Salary/Loan: ${transaction.salaryLoanMonth}',
                                            style: TextStyle(color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.account_balance, 
                                               size: 16, color: Colors.blue.shade700),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Balance: ₹${transaction.netBalance.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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