import 'package:flutter/material.dart';
import '../../models/bank_transaction.dart';
import '../../services/data_service.dart';

class AddBankTransactionScreen extends StatefulWidget {
  final String bankName;
  
  const AddBankTransactionScreen({super.key, required this.bankName});

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
  List<String> _parties = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    try {
      _parties = await DataService.getParty();
      if (_parties.isNotEmpty) {
        _selectedParty = _parties.first;
      }
      setState(() {});
    } catch (e) {
      print('Error loading parties: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _creditController.dispose();
    _debitController.dispose();
    _salaryLoanMonthController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveBankTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double credit = double.tryParse(_creditController.text) ?? 0.0;
    final double debit = double.tryParse(_debitController.text) ?? 0.0;

    if (credit == 0.0 && debit == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter either credit or debit amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (credit > 0.0 && debit > 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter either credit OR debit, not both'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current balance
      final transactions = await DataService.getBankTransactions();
      double currentBalance = 0.0;
      for (var transaction in transactions) {
        if (transaction.bankName == widget.bankName) {
          currentBalance += transaction.credit - transaction.debit;
        }
      }

      // Calculate new balance
      final double newBalance = currentBalance + credit - debit;

      final bankTransaction = BankTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _formatDate(_selectedDate),
        description: _descriptionController.text.trim(),
        credit: credit,
        debit: debit,
        netBalance: newBalance,
        party: _selectedParty ?? '',
        salaryLoanMonth: _salaryLoanMonthController.text.trim(),
        bankName: widget.bankName,
      );

      await DataService.addBankTransaction(bankTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank transaction saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bank Transaction'),
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
              // Current Bank Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Adding transaction to:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.bankName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Date Field
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Date: ${_formatDate(_selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Credit and Debit Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Credit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add, color: Colors.green),
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _debitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Debit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.remove, color: Colors.red),
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Party Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedParty,
                decoration: const InputDecoration(
                  labelText: 'Party',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
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
                hint: const Text('Select Party'),
              ),
              const SizedBox(height: 16),

              // Salary/Loan Month Field
              TextFormField(
                controller: _salaryLoanMonthController,
                decoration: const InputDecoration(
                  labelText: 'Salary/Loan Month',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                  hintText: 'e.g., January 2024',
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBankTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Bank Transaction',
                          style: TextStyle(fontSize: 16),
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