import 'package:flutter/material.dart';
import '../../models/bank_transaction.dart';
import '../../services/data_service.dart';

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
  List<String> _parties = [];

  void _saveTransaction() async {
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

      await DataService.saveBankTransaction(transaction);
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
                  items: _parties.map((String value) {
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