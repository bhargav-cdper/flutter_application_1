import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bank_transaction.dart';
import '../../services/data_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final BankTransaction transaction;
  final String bankName;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.bankName,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
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
    
    // Pre-fill form with existing transaction data
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
      // Delete old transaction
      bool deleteSuccess = await DataService.deleteBankTransaction(widget.transaction.id);
      
      if (deleteSuccess) {
        // Create new transaction with updated data
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
      } else {
        _showSnackBar('Failed to update transaction');
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
              // Bank Information
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

              // Date Selection
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

              // Description
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

              // Credit/Debit Toggle
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

              // Amount Input
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

              // Party Dropdown
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

              // Salary/Loan Month
              TextFormField(
                controller: _salaryLoanMonthController,
                decoration: const InputDecoration(
                  labelText: 'Salary/Loan Month',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., January 2024',
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
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