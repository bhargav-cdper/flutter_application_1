import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseManagementApp());
}

class ExpenseManagementApp extends StatelessWidget {
  const ExpenseManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Data Models
class ExpenseIncomeRecord {
  final String id;
  final String cashBank;
  final DateTime date;
  final String job;
  final String details;
  final String unit;
  final double qty;
  final double rate;
  final double credit;
  final double debit;
  final double netAmount;
  final String account;
  final String staffPersonalParty;

  ExpenseIncomeRecord({
    required this.id,
    required this.cashBank,
    required this.date,
    required this.job,
    required this.details,
    required this.unit,
    required this.qty,
    required this.rate,
    required this.credit,
    required this.debit,
    required this.netAmount,
    required this.account,
    required this.staffPersonalParty,
  });
}

class BankTransaction {
  final String id;
  final DateTime date;
  final String description;
  final double credit;
  final double debit;
  final double netBalance;
  final String party;
  final String salaryLoanMonth;
  final String bankName;

  BankTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.credit,
    required this.debit,
    required this.netBalance,
    required this.party,
    required this.salaryLoanMonth,
    required this.bankName,
  });
}

// Data Service
class DataService {
  static final List<String> _jobs = ['Construction', 'Renovation', 'Maintenance', 'Consultation'];
  static final List<String> _accounts = ['Office Expenses', 'Material Cost', 'Labor Cost', 'Transport'];
  static final List<String> _cashBank = ['Cash', 'SBI Bank', 'HDFC Bank', 'ICICI Bank'];
  static final List<String> _parties = ['ABC Suppliers', 'XYZ Contractors', 'PQR Materials', 'Staff Salary'];
  static final List<ExpenseIncomeRecord> _expenseIncomeRecords = [];
  static final List<BankTransaction> _bankTransactions = [];

  static List<String> getJobs() => List.from(_jobs);
  static List<String> getAccounts() => List.from(_accounts);
  static List<String> getCashBank() => List.from(_cashBank);
  static List<String> getParties() => List.from(_parties);

  static void saveExpenseIncomeRecord(ExpenseIncomeRecord record) {
    _expenseIncomeRecords.add(record);
  }

  static List<ExpenseIncomeRecord> getExpenseIncomeRecords() {
    return List.from(_expenseIncomeRecords);
  }

  static void saveBankTransaction(BankTransaction transaction) {
    _bankTransactions.add(transaction);
  }

  static List<BankTransaction> getBankTransactionsByBank(String bankName) {
    return _bankTransactions.where((transaction) => transaction.bankName == bankName).toList();
  }

  static double getBankBalance(String bankName) {
    double balance = 0.0;
    final bankTransactions = getBankTransactionsByBank(bankName);
    for (var transaction in bankTransactions) {
      balance += transaction.credit - transaction.debit;
    }
    return balance;
  }

  static List<String> getBanksWithTransactions() {
    Set<String> banks = {};
    for (var transaction in _bankTransactions) {
      if (transaction.bankName.isNotEmpty) {
        banks.add(transaction.bankName);
      }
    }
    return banks.toList();
  }

  static void addJob(String job) {
    if (!_jobs.contains(job)) {
      _jobs.add(job);
    }
  }

  static void addAccount(String account) {
    if (!_accounts.contains(account)) {
      _accounts.add(account);
    }
  }

  static void addCashBank(String cashBank) {
    if (!_cashBank.contains(cashBank)) {
      _cashBank.add(cashBank);
    }
  }

  static void addParty(String party) {
    if (!_parties.contains(party)) {
      _parties.add(party);
    }
  }

  static void removeJob(int index) {
    if (index >= 0 && index < _jobs.length) {
      _jobs.removeAt(index);
    }
  }

  static void removeAccount(int index) {
    if (index >= 0 && index < _accounts.length) {
      _accounts.removeAt(index);
    }
  }

  static void removeCashBank(int index) {
    if (index >= 0 && index < _cashBank.length) {
      _cashBank.removeAt(index);
    }
  }

  static void removeParty(int index) {
    if (index >= 0 && index < _parties.length) {
      _parties.removeAt(index);
    }
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final String dummyUsername = "admin";
  final String dummyPassword = "admin123";

  @override
  void initState() {
    super.initState();
    _usernameController.text = dummyUsername;
    _passwordController.text = dummyPassword;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_usernameController.text == dummyUsername &&
          _passwordController.text == dummyPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
                    const SizedBox(height: 20),
                    Text(
                      'Expense Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text('LOGIN', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Column(
                        children: [
                          Text('Demo Login Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Username: admin'),
                          Text('Password: admin123'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ExpenseIncomeScreen(),
          BankTransactionScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Expense/Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Bank Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Expense/Income Screen
class ExpenseIncomeScreen extends StatefulWidget {
  const ExpenseIncomeScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseIncomeScreen> createState() => _ExpenseIncomeScreenState();
}

class _ExpenseIncomeScreenState extends State<ExpenseIncomeScreen> {
  List<ExpenseIncomeRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _records = DataService.getExpenseIncomeRecords();
    setState(() {});
  }

  void _openAddRecordForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseIncomeScreen()),
    ).then((_) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense/Income'),
        automaticallyImplyLeading: false,
        actions: [
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
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _openAddRecordForm,
                icon: const Icon(Icons.add),
                label: const Text('Add Record'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: _records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No records found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the "Add Record" button to create your first record',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[_records.length - 1 - index];
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
                                      record.details,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '₹${record.netAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: record.netAmount >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Job: ${record.job}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Text('Date: ${record.date.toString().split(' ')[0]}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              if (record.credit > 0)
                                Text('Credit: ₹${record.credit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                              if (record.debit > 0)
                                Text('Debit: ₹${record.debit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.red)),
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

// Add Expense/Income Screen
class AddExpenseIncomeScreen extends StatefulWidget {
  const AddExpenseIncomeScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseIncomeScreen> createState() => _AddExpenseIncomeScreenState();
}

class _AddExpenseIncomeScreenState extends State<AddExpenseIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _unitController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _creditController = TextEditingController();
  final _debitController = TextEditingController();

  String? _selectedCashBank;
  DateTime _selectedDate = DateTime.now();
  String? _selectedJob;
  String? _selectedAccount;
  String? _selectedStaffPersonalParty;

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      final record = ExpenseIncomeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cashBank: _selectedCashBank ?? '',
        date: _selectedDate,
        job: _selectedJob ?? '',
        details: _detailsController.text,
        unit: _unitController.text,
        qty: double.tryParse(_qtyController.text) ?? 0.0,
        rate: double.tryParse(_rateController.text) ?? 0.0,
        credit: double.tryParse(_creditController.text) ?? 0.0,
        debit: double.tryParse(_debitController.text) ?? 0.0,
        netAmount: (double.tryParse(_creditController.text) ?? 0.0) - (double.tryParse(_debitController.text) ?? 0.0),
        account: _selectedAccount ?? '',
        staffPersonalParty: _selectedStaffPersonalParty ?? '',
      );

      DataService.saveExpenseIncomeRecord(record);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCashBank,
                  decoration: const InputDecoration(
                    labelText: 'CASH/BANK',
                    border: OutlineInputBorder(),
                  ),
                  items: DataService.getCashBank().map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCashBank = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'DATE',
                      border: OutlineInputBorder(),
                    ),
                    child: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedJob,
                  decoration: const InputDecoration(
                    labelText: 'JOB',
                    border: OutlineInputBorder(),
                  ),
                  items: DataService.getJobs().map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJob = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'DETAILS',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'UNIT',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(
                    labelText: 'QTY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: 'RATE',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _creditController,
                  decoration: const InputDecoration(
                    labelText: 'CREDIT',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _debitController,
                  decoration: const InputDecoration(
                    labelText: 'DEBIT',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedAccount,
                  decoration: const InputDecoration(
                    labelText: 'ACCOUNT',
                    border: OutlineInputBorder(),
                  ),
                  items: DataService.getAccounts().map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAccount = newValue;
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedStaffPersonalParty,
                  decoration: const InputDecoration(
                    labelText: 'STAFF/PERSONAL-PARTY',
                    border: OutlineInputBorder(),
                  ),
                  items: DataService.getParties().map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStaffPersonalParty = newValue;
                    });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text('SAVE RECORD', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bank Transaction Screen
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

  void _loadData() {
    _bankOptions = DataService.getCashBank().where((bank) => bank != 'Cash').toList();
    
    final banksWithTransactions = DataService.getBanksWithTransactions();
    for (String bank in banksWithTransactions) {
      if (!_bankOptions.contains(bank)) {
        _bankOptions.add(bank);
      }
    }
    
    if (_selectedBank != null) {
      _transactions = DataService.getBankTransactionsByBank(_selectedBank!);
      _currentBalance = DataService.getBankBalance(_selectedBank!);
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
                final bankBalance = DataService.getBankBalance(bank);
                final transactionCount = DataService.getBankTransactionsByBank(bank).length;
                
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => _selectBank(bank),
                    child: Column(
                      children: [
                        Text(bank, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('Balance: ₹${bankBalance.toStringAsFixed(2)}', 
                             style: TextStyle(fontSize: 14, color: bankBalance >= 0 ? Colors.green : Colors.red)),
                        Text('$transactionCount transactions', 
                             style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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

// Add Bank Transaction Screen
class AddBankTransactionScreen extends StatefulWidget {
  final String selectedBank;
  final double currentBalance;

  const AddBankTransactionScreen({
    Key? key,
    required this.selectedBank,
    required this.currentBalance,
  }) : super(key: key);

  @override
  State<AddBankTransactionScreen> createState() => _AddBankTransactionScreenState();
}

class _AddBankTransactionScreenState extends State<AddBankTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _creditController = TextEditingController();
  final _debitController = TextEditingController();
  final _salaryLoanMonthController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedParty;

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      double credit = double.tryParse(_creditController.text) ?? 0.0;
      double debit = double.tryParse(_debitController.text) ?? 0.0;
      double newBalance = widget.currentBalance + credit - debit;

      final transaction = BankTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        description: _descriptionController.text,
        credit: credit,
        debit: debit,
        netBalance: newBalance,
        party: _selectedParty ?? '',
        salaryLoanMonth: _salaryLoanMonthController.text,
        bankName: widget.selectedBank,
      );

      DataService.saveBankTransaction(transaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.selectedBank} Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.selectedBank} - Current Balance: ₹${widget.currentBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.currentBalance >= 0 ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _creditController,
                  decoration: const InputDecoration(
                    labelText: 'Credit',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _debitController,
                  decoration: const InputDecoration(
                    labelText: 'Debit',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedParty,
                  decoration: const InputDecoration(
                    labelText: 'Party',
                    border: OutlineInputBorder(),
                  ),
                  items: DataService.getParties().map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedParty = newValue;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _salaryLoanMonthController,
                  decoration: const InputDecoration(
                    labelText: 'Salary/Loan Month',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text('SAVE TRANSACTION', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _jobs = [];
  List<String> _accounts = [];
  List<String> _cashBank = [];
  List<String> _parties = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _jobs = DataService.getJobs();
    _accounts = DataService.getAccounts();
    _cashBank = DataService.getCashBank();
    _parties = DataService.getParties();
    setState(() {});
  }

  void _addItem(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItem = '';
        return AlertDialog(
          title: Text('Add $category'),
          content: TextField(
            onChanged: (value) {
              newItem = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newItem.isNotEmpty) {
                  switch (category) {
                    case 'Job':
                      DataService.addJob(newItem);
                      break;
                    case 'Account':
                      DataService.addAccount(newItem);
                      break;
                    case 'Cash/Bank':
                      DataService.addCashBank(newItem);
                      break;
                    case 'Party':
                      DataService.addParty(newItem);
                      break;
                  }
                  _loadData();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$category added successfully!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String category, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                switch (category) {
                  case 'Job':
                    DataService.removeJob(index);
                    break;
                  case 'Account':
                    DataService.removeAccount(index);
                    break;
                  case 'Cash/Bank':
                    DataService.removeCashBank(index);
                    break;
                  case 'Party':
                    DataService.removeParty(index);
                    break;
                }
                _loadData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<String> items, String category) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addItem(category),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(category, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade100,
              child: Column(
                children: [
                  Icon(Icons.settings, size: 40, color: Colors.blue.shade800),
                  const SizedBox(height: 8),
                  Text(
                    'Manage Default Data',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                  Text(
                    'Add or remove options for dropdown menus',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ],
              ),
            ),
            _buildCategorySection('Jobs', _jobs, 'Job'),
            _buildCategorySection('Accounts', _accounts, 'Account'),
            _buildCategorySection('Cash/Bank Options', _cashBank, 'Cash/Bank'),
            _buildCategorySection('Parties', _parties, 'Party'),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade800),
                  const SizedBox(height: 8),
                  Text(
                    'Note: Data Storage',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This app stores data in memory during the current session. Data will be lost when the app is restarted.',
                    style: TextStyle(color: Colors.orange.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}