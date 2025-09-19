import 'package:flutter/material.dart';
import '../../models/expense_income_record.dart';
import '../../services/data_service.dart';
import '../login_screen.dart';
import 'add_expense_income_screen.dart';

class ExpenseIncomeScreen extends StatefulWidget {
  const ExpenseIncomeScreen({super.key});

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

  void _loadData() async {
    final records = await DataService.getExpenseIncomeRecords();
    setState(() {
      _records = records;
    });
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