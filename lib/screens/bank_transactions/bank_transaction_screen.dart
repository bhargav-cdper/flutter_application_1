import 'package:flutter/material.dart';
import '../../models/bank_transaction.dart';
import '../../services/data_service.dart';
import '../login_screen.dart';
import 'add_bank_transaction_screen.dart';

class BankTransactionScreen extends StatefulWidget {
  const BankTransactionScreen({Key? key}) : super(key: key);

  @override
  State<BankTransactionScreen> createState() => _BankTransactionScreenState();
}

class _BankTransactionScreenState extends State<BankTransactionScreen> {
  List<String> _bankOptions = [];
  List<BankTransaction> _transactions = [];
  String? _selectedBank;
  double _currentBalance = 0.0;
  bool _bankSelected = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Load fresh data into cache first
    await DataService.getCashBankAsync();
    final allCashBank = DataService.getCashBank();
    _bankOptions = allCashBank.where((bank) => bank != 'Cash').toList();
    
    final banksWithTransactions = await DataService.getBanksWithTransactions();
    for (String bank in banksWithTransactions) {
      if (!_bankOptions.contains(bank)) {
        _bankOptions.add(bank);
      }
    }
    
    if (_selectedBank != null) {
      _transactions = await DataService.getBankTransactionsByBank(_selectedBank!);
      _currentBalance = await DataService.getBankBalance(_selectedBank!);
    }
    setState(() {});
  }

  void _selectBank(String bankName) {
    setState(() {
      _selectedBank = bankName;
      _bankSelected = true;
    });
    _loadData();
  }

  void _changeBankSelection() {
    setState(() {
      _bankSelected = false;
      _selectedBank = null;
      _transactions = [];
      _currentBalance = 0.0;
    });
  }

  void _openAddTransactionForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBankTransactionScreen(
          selectedBank: _selectedBank!,
          currentBalance: _currentBalance,
        ),
      ),
    ).then((_) {
      _loadData();
    });
  }

  Widget _buildBankSelectionScreen() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                'Select Bank Statement',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
              const SizedBox(height: 30),
              ..._bankOptions.map((bank) {
                double bankBalance = 0.0;
                int transactionCount = 0;
                // Note: These will be calculated async, but we'll show 0 initially
                // and update with proper values when _loadBankStats() is called
                
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => _selectBank(bank),
                    child: Column(
                      children: [
                        Text(bank, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        FutureBuilder<double>(
                          future: DataService.getBankBalance(bank),
                          builder: (context, snapshot) {
                            final balance = snapshot.data ?? 0.0;
                            return Text('Balance: ₹${balance.toStringAsFixed(2)}', 
                                       style: TextStyle(fontSize: 14, color: balance >= 0 ? Colors.green : Colors.red));
                          },
                        ),
                        FutureBuilder<List<BankTransaction>>(
                          future: DataService.getBankTransactionsByBank(bank),
                          builder: (context, snapshot) {
                            final transactions = snapshot.data ?? [];
                            return Text('${transactions.length} transactions', 
                                       style: TextStyle(fontSize: 12, color: Colors.grey.shade600));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bankSelected ? '$_selectedBank Transactions' : 'Bank Transactions'),
        automaticallyImplyLeading: false,
        actions: [
          if (_bankSelected)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: _changeBankSelection,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: !_bankSelected
          ? _buildBankSelectionScreen()
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Text(
                    '$_selectedBank - Balance: ₹${_currentBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _currentBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _openAddTransactionForm,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Transaction'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance, size: 80, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text('No transactions found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[_transactions.length - 1 - index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            transaction.description,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if (transaction.credit > 0)
                                              Text('+₹${transaction.credit.toStringAsFixed(2)}', 
                                                   style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                            if (transaction.debit > 0)
                                              Text('-₹${transaction.debit.toStringAsFixed(2)}', 
                                                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Date: ${transaction.date.toString().split(' ')[0]}', 
                                         style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text('Party: ${transaction.party}', 
                                         style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text('Balance: ₹${transaction.netBalance.toStringAsFixed(2)}', 
                                         style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}