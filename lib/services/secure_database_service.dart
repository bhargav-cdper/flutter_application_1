import 'dart:io';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/expense_income_record.dart';
import '../models/bank_transaction.dart';

class SecureDatabaseService {
  static Database? _database;
  static const String _databaseName = 'expense_management_secure.db';
  static const int _databaseVersion = 1;

  // Initialize database
  static Future<void> initialize() async {
    // Initialize ffi loader for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await _initDatabase();
    await _createTables();
  }

  static Future<void> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbDirectory = Directory(join(documentsDirectory.path, 'ExpenseManagement'));
    
    // Create directory if it doesn't exist
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }

    final path = join(dbDirectory.path, _databaseName);
    
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createTables();
      },
    );
  }

  static Future<void> _createTables() async {
    if (_database == null) return;

    // Create dropdown options table
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS dropdown_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create expense income records table
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS expense_income_records (
        id TEXT PRIMARY KEY,
        cash_bank TEXT NOT NULL,
        date TEXT NOT NULL,
        job TEXT NOT NULL,
        details TEXT NOT NULL,
        unit TEXT,
        qty REAL NOT NULL DEFAULT 0,
        rate REAL NOT NULL DEFAULT 0,
        credit REAL NOT NULL DEFAULT 0,
        debit REAL NOT NULL DEFAULT 0,
        net_amount REAL NOT NULL DEFAULT 0,
        account TEXT,
        staff_personal_party TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create bank transactions table
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS bank_transactions (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        credit REAL NOT NULL DEFAULT 0,
        debit REAL NOT NULL DEFAULT 0,
        net_balance REAL NOT NULL DEFAULT 0,
        party TEXT,
        salary_loan_month TEXT,
        bank_name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create category names table for custom category titles
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS category_names (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_key TEXT UNIQUE NOT NULL,
        display_name TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert default dropdown options if not exists
    await _insertDefaultOptions();
  }

  static Future<void> _insertDefaultOptions() async {
    if (_database == null) return;

    final now = DateTime.now().toIso8601String();

    // Default jobs
    final defaultJobs = ['Construction', 'Renovation', 'Maintenance', 'Consultation'];
    for (String job in defaultJobs) {
      await _database!.rawInsert(
        'INSERT OR IGNORE INTO dropdown_options (category, value, created_at) VALUES (?, ?, ?)',
        ['Job', job, now],
      );
    }

    // Default accounts
    final defaultAccounts = ['Office Expenses', 'Material Cost', 'Labor Cost', 'Transport'];
    for (String account in defaultAccounts) {
      await _database!.rawInsert(
        'INSERT OR IGNORE INTO dropdown_options (category, value, created_at) VALUES (?, ?, ?)',
        ['Account', account, now],
      );
    }

    // Default cash/bank options
    final defaultCashBank = ['Cash', 'SBI Bank', 'HDFC Bank', 'ICICI Bank'];
    for (String cashBank in defaultCashBank) {
      await _database!.rawInsert(
        'INSERT OR IGNORE INTO dropdown_options (category, value, created_at) VALUES (?, ?, ?)',
        ['Cash/Bank', cashBank, now],
      );
    }

    // Default parties
    final defaultParties = ['ABC Suppliers', 'XYZ Contractors', 'PQR Materials', 'Staff Salary'];
    for (String party in defaultParties) {
      await _database!.rawInsert(
        'INSERT OR IGNORE INTO dropdown_options (category, value, created_at) VALUES (?, ?, ?)',
        ['Party', party, now],
      );
    }
  }

  // Dropdown options methods
  static Future<List<String>> getDropdownOptions(String category) async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> results = await _database!.query(
      'dropdown_options',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id ASC',
    );

    return results.map((row) => row['value'] as String).toList();
  }

  static Future<void> addDropdownOption(String category, String value) async {
    if (_database == null) return;

    await _database!.insert('dropdown_options', {
      'category': category,
      'value': value,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateDropdownOption(String category, String oldValue, String newValue) async {
    if (_database == null) return;

    await _database!.update(
      'dropdown_options',
      {'value': newValue},
      where: 'category = ? AND value = ?',
      whereArgs: [category, oldValue],
    );
  }

  static Future<void> deleteDropdownOption(String category, String value) async {
    if (_database == null) return;

    await _database!.delete(
      'dropdown_options',
      where: 'category = ? AND value = ?',
      whereArgs: [category, value],
    );
  }

  // Expense Income Records methods
  static Future<void> saveExpenseIncomeRecord(ExpenseIncomeRecord record) async {
    if (_database == null) return;

    await _database!.insert('expense_income_records', {
      'id': record.id,
      'cash_bank': record.cashBank,
      'date': record.date.toIso8601String(),
      'job': record.job,
      'details': record.details,
      'unit': record.unit,
      'qty': record.qty,
      'rate': record.rate,
      'credit': record.credit,
      'debit': record.debit,
      'net_amount': record.netAmount,
      'account': record.account,
      'staff_personal_party': record.staffPersonalParty,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<ExpenseIncomeRecord>> getExpenseIncomeRecords() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> results = await _database!.query(
      'expense_income_records',
      orderBy: 'created_at DESC',
    );

    return results.map((row) => ExpenseIncomeRecord(
      id: row['id'],
      cashBank: row['cash_bank'],
      date: DateTime.parse(row['date']),
      job: row['job'],
      details: row['details'],
      unit: row['unit'] ?? '',
      qty: row['qty']?.toDouble() ?? 0.0,
      rate: row['rate']?.toDouble() ?? 0.0,
      credit: row['credit']?.toDouble() ?? 0.0,
      debit: row['debit']?.toDouble() ?? 0.0,
      netAmount: row['net_amount']?.toDouble() ?? 0.0,
      account: row['account'] ?? '',
      staffPersonalParty: row['staff_personal_party'] ?? '',
    )).toList();
  }

  // Bank Transaction methods
  static Future<void> saveBankTransaction(BankTransaction transaction) async {
    if (_database == null) return;

    await _database!.insert('bank_transactions', {
      'id': transaction.id,
      'date': transaction.date.toIso8601String(),
      'description': transaction.description,
      'credit': transaction.credit,
      'debit': transaction.debit,
      'net_balance': transaction.netBalance,
      'party': transaction.party,
      'salary_loan_month': transaction.salaryLoanMonth,
      'bank_name': transaction.bankName,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<BankTransaction>> getBankTransactionsByBank(String bankName) async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> results = await _database!.query(
      'bank_transactions',
      where: 'bank_name = ?',
      whereArgs: [bankName],
      orderBy: 'created_at DESC',
    );

    return results.map((row) => BankTransaction(
      id: row['id'],
      date: DateTime.parse(row['date']),
      description: row['description'],
      credit: row['credit']?.toDouble() ?? 0.0,
      debit: row['debit']?.toDouble() ?? 0.0,
      netBalance: row['net_balance']?.toDouble() ?? 0.0,
      party: row['party'] ?? '',
      salaryLoanMonth: row['salary_loan_month'] ?? '',
      bankName: row['bank_name'],
    )).toList();
  }

  static Future<List<String>> getBanksWithTransactions() async {
    if (_database == null) return [];

    final List<Map<String, dynamic>> results = await _database!.rawQuery(
      'SELECT DISTINCT bank_name FROM bank_transactions WHERE bank_name IS NOT NULL AND bank_name != ""',
    );

    return results.map((row) => row['bank_name'] as String).toList();
  }

  static Future<double> getBankBalance(String bankName) async {
    if (_database == null) return 0.0;

    final List<Map<String, dynamic>> results = await _database!.rawQuery(
      'SELECT SUM(credit - debit) as balance FROM bank_transactions WHERE bank_name = ?',
      [bankName],
    );

    if (results.isNotEmpty && results.first['balance'] != null) {
      return results.first['balance'].toDouble();
    }
    return 0.0;
  }

  // Category names methods
  static Future<void> saveCategoryName(String categoryKey, String displayName) async {
    if (_database == null) return;

    await _database!.rawInsert(
      'INSERT OR REPLACE INTO category_names (category_key, display_name, updated_at) VALUES (?, ?, ?)',
      [categoryKey, displayName, DateTime.now().toIso8601String()],
    );
  }

  static Future<String?> getCategoryName(String categoryKey) async {
    if (_database == null) return null;

    final List<Map<String, dynamic>> results = await _database!.query(
      'category_names',
      where: 'category_key = ?',
      whereArgs: [categoryKey],
    );

    if (results.isNotEmpty) {
      return results.first['display_name'];
    }
    return null;
  }

  // Clear all data (for reset/logout)
  static Future<void> clearAllData() async {
    if (_database == null) return;

    await _database!.delete('dropdown_options');
    await _database!.delete('expense_income_records');
    await _database!.delete('bank_transactions');
    await _database!.delete('category_names');
    
    // Re-insert default options
    await _insertDefaultOptions();
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}