import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/expense_income_record.dart';

class AddExpenseIncomeScreen extends StatefulWidget {
  const AddExpenseIncomeScreen({super.key});

  @override
  _AddExpenseIncomeScreenState createState() => _AddExpenseIncomeScreenState();
}

class _AddExpenseIncomeScreenState extends State<AddExpenseIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _detailsController = TextEditingController();
  final _unitController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _creditController = TextEditingController();
  final _debitController = TextEditingController();
  final _netAmountController = TextEditingController();

  String? _selectedCashBank;
  String? _selectedJob;
  String? _selectedAccount;
  String? _selectedParty;

  List<String> _cashBankOptions = [];
  List<String> _jobOptions = [];
  List<String> _accountOptions = [];
  List<String> _partyOptions = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _dateController.text = DateTime.now().toString().split(' ')[0]; // Default to today's date
  }

  @override
  void dispose() {
    _dateController.dispose();
    _detailsController.dispose();
    _unitController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _creditController.dispose();
    _debitController.dispose();
    _netAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final cashBank = await DataService.getCashBank();
      final jobs = await DataService.getJobs();
      final accounts = await DataService.getAccounts();
      final parties = await DataService.getParty();

      setState(() {
        _cashBankOptions = cashBank;
        _jobOptions = jobs;
        _accountOptions = accounts;
        _partyOptions = parties;
      });
    } catch (e) {
      print("Error loading dropdown data: $e");
      _showSnackBar("Error loading data: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _calculateNetAmount() {
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final credit = double.tryParse(_creditController.text) ?? 0.0;
    final debit = double.tryParse(_debitController.text) ?? 0.0;
    
    // Calculate net amount as (qty * rate) + credit - debit
    final netAmount = (qty * rate) + credit - debit;
    _netAmountController.text = netAmount.toStringAsFixed(2);
  }

  Future<void> _saveExpenseIncomeRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final record = ExpenseIncomeRecord(
          cashBank: _selectedCashBank ?? '',
          date: _dateController.text,
          job: _selectedJob ?? '',
          details: _detailsController.text.trim(),
          unit: _unitController.text.trim(),
          qty: double.tryParse(_qtyController.text) ?? 0.0,
          rate: double.tryParse(_rateController.text) ?? 0.0,
          credit: double.tryParse(_creditController.text) ?? 0.0,
          debit: double.tryParse(_debitController.text) ?? 0.0,
          netAmount: double.tryParse(_netAmountController.text) ?? 0.0,
          account: _selectedAccount ?? '',
          staffPersonalParty: _selectedParty ?? '',
        );

        // Use the correct method name from DataService
        final success = await DataService.addExpenseIncomeRecord(record);
        
        if (success) {
          _showSnackBar('Record saved successfully!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          _showSnackBar('Failed to save record');
        }
      } catch (e) {
        print("Error saving record: $e");
        _showSnackBar('Error saving record: $e');
      } finally {
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
        title: const Text('Add Expense/Income'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveExpenseIncomeRecord,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Cash/Bank Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCashBank,
                decoration: const InputDecoration(
                  labelText: 'Cash/Bank *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: _cashBankOptions.map((String cashBank) {
                  return DropdownMenuItem<String>(
                    value: cashBank,
                    child: Text(cashBank),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCashBank = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select cash/bank';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Field
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedJob,
                decoration: const InputDecoration(
                  labelText: 'Job *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                items: _jobOptions.map((String job) {
                  return DropdownMenuItem<String>(
                    value: job,
                    child: Text(job),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJob = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select job';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Details Field
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Unit, Qty, Rate Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateNetAmount(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: 'Rate',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateNetAmount(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Credit and Debit Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _creditController,
                      decoration: const InputDecoration(
                        labelText: 'Credit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add, color: Colors.green),
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateNetAmount(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _debitController,
                      decoration: const InputDecoration(
                        labelText: 'Debit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.remove, color: Colors.red),
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateNetAmount(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Net Amount Field (Auto-calculated)
              TextFormField(
                controller: _netAmountController,
                decoration: const InputDecoration(
                  labelText: 'Net Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
                style: TextStyle(
                  color: _netAmountController.text.startsWith('-') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Account Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedAccount,
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                items: _accountOptions.map((String account) {
                  return DropdownMenuItem<String>(
                    value: account,
                    child: Text(account),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAccount = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Staff/Personal/Party Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedParty,
                decoration: const InputDecoration(
                  labelText: 'Staff/Personal/Party',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: _partyOptions.map((String party) {
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
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpenseIncomeRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Saving...'),
                        ],
                      )
                    : const Text('Save Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}