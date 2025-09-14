import 'package:flutter/material.dart';
import '../../models/expense_income_record.dart';
import '../../services/data_service.dart';

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

  // ADD THESE FOUR LINES MANUALLY:
  List<String> _cashBankOptions = [];
  List<String> _jobOptions = [];
  List<String> _accountOptions = [];
  List<String> _partyOptions = [];

  void _saveRecord() async {
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

      await DataService.saveExpenseIncomeRecord(record);
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
                  items: _accountOptions.map((String value) {
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
                  items: _partyOptions.map((String value) {
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