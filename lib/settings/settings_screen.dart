import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedCategory;
  List<String> _currentItems = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Jobs',
      'icon': Icons.work,
      'color': Colors.blue,
      'key': 'Job',
    },
    {
      'title': 'Accounts',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'key': 'Account',
    },
    {
      'title': 'Cash/Bank Options',
      'icon': Icons.account_balance,
      'color': Colors.orange,
      'key': 'Cash/Bank',
    },
    {
      'title': 'Parties',
      'icon': Icons.people,
      'color': Colors.purple,
      'key': 'Party',
    },
  ];

  void _loadCategoryData(String category) {
    switch (category) {
      case 'Job':
        _currentItems = DataService.getJobs();
        break;
      case 'Account':
        _currentItems = DataService.getAccounts();
        break;
      case 'Cash/Bank':
        _currentItems = DataService.getCashBank();
        break;
      case 'Party':
        _currentItems = DataService.getParties();
        break;
    }
    setState(() {});
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadCategoryData(category);
  }

  void _goBackToCategories() {
    setState(() {
      _selectedCategory = null;
      _currentItems = [];
    });
  }

  void _editCategoryName(int categoryIndex) {
    String currentTitle = _categories[categoryIndex]['title'];
    TextEditingController editController = TextEditingController(text: currentTitle);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category Name'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Enter category name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String editedTitle = editController.text.trim();
                
                if (editedTitle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category name cannot be empty!')),
                  );
                  return;
                }
                
                if (editedTitle == currentTitle) {
                  Navigator.of(context).pop();
                  return;
                }
                
                // Check if category name already exists
                bool titleExists = _categories.any((cat) => 
                    cat['title'] == editedTitle && cat != _categories[categoryIndex]);
                
                if (titleExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category name already exists!')),
                  );
                  return;
                }
                
                // Update the category title
                setState(() {
                  _categories[categoryIndex]['title'] = editedTitle;
                });
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category name updated successfully!')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItem = '';
        return AlertDialog(
          title: Text('Add $_selectedCategory'),
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
              onPressed: () async {
                String trimmedItem = newItem.trim();
                
                if (trimmedItem.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty!')),
                  );
                  return;
                }
                
                // Check if item already exists
                bool itemExists = false;
                switch (_selectedCategory) {
                  case 'Job':
                    final jobs = await DataService.getJobs();
                    itemExists = jobs.contains(trimmedItem);
                    break;
                  case 'Account':
                    final accounts = await DataService.getAccounts();
                    itemExists = accounts.contains(trimmedItem);
                    break;
                  case 'Cash/Bank':
                    final cashBank = await DataService.getCashBank();
                    itemExists = cashBank.contains(trimmedItem);
                    break;
                  case 'Party':
                    final parties = await DataService.getParties();
                    itemExists = parties.contains(trimmedItem);
                    break;
                }
                
                if (itemExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$_selectedCategory already exists!')),
                  );
                  return;
                }
                
                // Add the item
                switch (_selectedCategory) {
                  case 'Job':
                    DataService.addJob(trimmedItem);
                    break;
                  case 'Account':
                    DataService.addAccount(trimmedItem);
                    break;
                  case 'Cash/Bank':
                    DataService.addCashBank(trimmedItem);
                    break;
                  case 'Party':
                    DataService.addParty(trimmedItem);
                    break;
                }
                
                _loadCategoryData(_selectedCategory!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$_selectedCategory added successfully!')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(int index) {
    String currentItem = _currentItems[index];
    TextEditingController editController = TextEditingController(text: currentItem);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $_selectedCategory'),
          content: TextField(
            controller: editController,
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
                String editedItem = editController.text.trim();
                
                if (editedItem.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty!')),
                  );
                  return;
                }
                
                if (editedItem == currentItem) {
                  Navigator.of(context).pop();
                  return;
                }
                
                // Check if item already exists (excluding current item)
                bool itemExists = false;
                switch (_selectedCategory) {
                  case 'Job':
                    itemExists = DataService.getJobs().contains(editedItem);
                    break;
                  case 'Account':
                    itemExists = DataService.getAccounts().contains(editedItem);
                    break;
                  case 'Cash/Bank':
                    itemExists = DataService.getCashBank().contains(editedItem);
                    break;
                  case 'Party':
                    itemExists = DataService.getParties().contains(editedItem);
                    break;
                }
                
                if (itemExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item already exists!')),
                  );
                  return;
                }
                
                // Update the item
                switch (_selectedCategory) {
                  case 'Job':
                    DataService.editJob(index, editedItem);
                    break;
                  case 'Account':
                    DataService.editAccount(index, editedItem);
                    break;
                  case 'Cash/Bank':
                    DataService.editCashBank(index, editedItem);
                    break;
                  case 'Party':
                    DataService.editParty(index, editedItem);
                    break;
                }
                
                _loadCategoryData(_selectedCategory!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$_selectedCategory updated successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${_currentItems[index]}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                switch (_selectedCategory) {
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
                _loadCategoryData(_selectedCategory!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
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
                'Select a category to manage its options',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category['color'].shade100,
                    child: Icon(
                      category['icon'],
                      color: category['color'],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    category['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${_getCategoryCount(category['key'])} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => _editCategoryName(index),
                        tooltip: 'Edit category name',
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                  onTap: () => _selectCategory(category['key']),
                ),
              );
            },
          ),
        ),
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
    );
  }

  Widget _buildCategoryItems() {
    final categoryData = _categories.firstWhere((cat) => cat['key'] == _selectedCategory);
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: categoryData['color'].shade100,
          child: Row(
            children: [
              Icon(categoryData['icon'], size: 32, color: categoryData['color'].shade800),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryData['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: categoryData['color'].shade800,
                      ),
                    ),
                    Text(
                      'Manage ${categoryData['title'].toLowerCase()} options',
                      style: TextStyle(color: categoryData['color'].shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: categoryData['color'],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: _currentItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categoryData['icon'], size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No items found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the "Add" button to create your first item',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _currentItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: categoryData['color'].shade100,
                          child: Icon(categoryData['icon'], color: categoryData['color']),
                        ),
                        title: Text(
                          _currentItems[index],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editItem(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(index),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  int _getCategoryCount(String category) {
    switch (category) {
      case 'Job':
        return DataService.getJobs().length;
      case 'Account':
        return DataService.getAccounts().length;
      case 'Cash/Bank':
        return DataService.getCashBank().length;
      case 'Party':
        return DataService.getParties().length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory == null ? 'Settings' : _selectedCategory!),
        automaticallyImplyLeading: false,
        leading: _selectedCategory != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToCategories,
              )
            : null,
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
      body: _selectedCategory == null ? _buildCategoriesGrid() : _buildCategoryItems(),
    );
  }
}