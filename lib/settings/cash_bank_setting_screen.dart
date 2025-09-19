import 'package:flutter/material.dart';
import '../services/data_service.dart';

class CashBankSettingScreen extends StatefulWidget {
  const CashBankSettingScreen({super.key});

  @override
  _CashBankSettingScreenState createState() => _CashBankSettingScreenState();
}

class _CashBankSettingScreenState extends State<CashBankSettingScreen> {
  List<String> cashBankOptions = [];

  @override
  void initState() {
    super.initState();
    _loadCashBankOptions();
  }

  _loadCashBankOptions() async {
    cashBankOptions = await DataService.getCashBank();
    setState(() {});
  }

  _showAddDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cash/Bank Option'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter cash/bank option',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await DataService.addCashBank(controller.text);
                _loadCashBankOptions();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cash/Bank option added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  _confirmDelete(String option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cash/Bank Option'),
        content: Text('Are you sure you want to delete "$option"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DataService.deleteCashBank(option);
              _loadCashBankOptions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cash/Bank option deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash/Bank Options'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: cashBankOptions.isEmpty
          ? const Center(
              child: Text(
                'No cash/bank options available\nTap + to add an option',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cashBankOptions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: Colors.blue),
                    title: Text(cashBankOptions[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(cashBankOptions[index]),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}