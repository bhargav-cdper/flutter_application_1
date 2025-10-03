import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import '../models/expense_income_record.dart';
import '../models/bank_transaction.dart';
import '../constants/app_constants.dart';

class DataService {
  static Database? _database;
  static String? _portableDataPath;
  
  // Initialize portable mode with custom data directory
  static Future<void> initializePortableMode(String dataDirectory) async {
    _portableDataPath = dataDirectory;
    await _ensureDataDirectory();
  }
  
  // Get the portable data path
  static String getPortableDataPath() {
    if (_portableDataPath != null) {
      return _portableDataPath!;
    }
    
    // Default to executable directory + data folder
    if (Platform.isWindows) {
      final executableDir = path.dirname(Platform.resolvedExecutable);
      return path.join(executableDir, 'data');
    } else {
      return path.join(Directory.current.path, 'data');
    }
  }
  
  // Ensure data directory exists
  static Future<void> _ensureDataDirectory() async {
    final dataPath = getPortableDataPath();
    final dataDir = Directory(dataPath);
    
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    
    // Create backup directory
    final backupDir = Directory(path.join(dataPath, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
  }
  
  // Initialize database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    await _ensureDataDirectory();
    
    final dbPath = path.join(getPortableDataPath(), 'expense_management.db');
    
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDb,
      onOpen: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }
  
  static Future<void> _createDb(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE expense_income_records (
        id TEXT PRIMARY KEY,
        cashBank TEXT NOT NULL,
        date TEXT NOT NULL,
        job TEXT NOT NULL,
        details TEXT NOT NULL,
        unit TEXT,
        qty REAL DEFAULT 0,
        rate REAL DEFAULT 0,
        credit REAL DEFAULT 0,
        debit REAL DEFAULT 0,
        netAmount REAL DEFAULT 0,
        account TEXT,
        staffPersonalParty TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await db.execute('''
      CREATE TABLE bank_transactions (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        credit REAL DEFAULT 0,
        debit REAL DEFAULT 0,
        netBalance REAL DEFAULT 0,
        party TEXT,
        salaryLoanMonth TEXT,
        bankName TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_expense_date ON expense_income_records(date)');
    await db.execute('CREATE INDEX idx_bank_date ON bank_transactions(date)');
    await db.execute('CREATE INDEX idx_bank_name ON bank_transactions(bankName)');
  }
  
  // Settings management (instead of SharedPreferences)
  static Future<void> _saveSetting(String key, List<String> values) async {
    final db = await database;
    final valuesJson = values.join('|'); // Simple delimiter
    
    await db.insert(
      'settings',
      {
        'key': key,
        'value': valuesJson,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<List<String>> _getSetting(String key, List<String> defaultValues) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (result.isNotEmpty) {
      final valuesJson = result.first['value'] as String;
      // FIXED: Create a new modifiable list from the split result
      return List<String>.from(valuesJson.split('|').where((s) => s.isNotEmpty));
    }
    
    // FIXED: Return a modifiable copy of default values
    return List<String>.from(defaultValues);
  }
  
  // Initialize default data
  static Future<void> initializeDefaultData() async {
    // Check if data already exists
    final jobs = await getJobs();
    if (jobs.isEmpty) {
      await _saveSetting('jobs', AppConstants.defaultJobs);
    }
    
    final accounts = await getAccounts();
    if (accounts.isEmpty) {
      await _saveSetting('accounts', AppConstants.defaultAccounts);
    }
    
    final cashBank = await getCashBank();
    if (cashBank.isEmpty) {
      await _saveSetting('cashBank', AppConstants.defaultCashBank);
    }
    
    final parties = await getParty();
    if (parties.isEmpty) {
      await _saveSetting('parties', AppConstants.defaultParties);
    }
  }
  
  // Jobs management
  static Future<List<String>> getJobs() async {
    return await _getSetting('jobs', AppConstants.defaultJobs);
  }
  
  static Future<void> addJob(String job) async {
    final jobs = await getJobs();
    if (!jobs.contains(job)) {
      jobs.add(job);
      await _saveSetting('jobs', jobs);
    }
  }
  
  static Future<void> deleteJob(String job) async {
    final jobs = await getJobs();
    jobs.remove(job);
    await _saveSetting('jobs', jobs);
  }
  
  // Accounts management
  static Future<List<String>> getAccounts() async {
    return await _getSetting('accounts', AppConstants.defaultAccounts);
  }
  
  static Future<void> addAccount(String account) async {
    final accounts = await getAccounts();
    if (!accounts.contains(account)) {
      accounts.add(account);
      await _saveSetting('accounts', accounts);
    }
  }
  
  static Future<void> deleteAccount(String account) async {
    final accounts = await getAccounts();
    accounts.remove(account);
    await _saveSetting('accounts', accounts);
  }
  
  // Cash/Bank management
  static Future<List<String>> getCashBank() async {
    return await _getSetting('cashBank', AppConstants.defaultCashBank);
  }
  
  static Future<void> addCashBank(String cashBank) async {
    final cashBankList = await getCashBank();
    if (!cashBankList.contains(cashBank)) {
      cashBankList.add(cashBank);
      await _saveSetting('cashBank', cashBankList);
    }
  }
  
  static Future<void> deleteCashBank(String cashBank) async {
    final cashBankList = await getCashBank();
    cashBankList.remove(cashBank);
    await _saveSetting('cashBank', cashBankList);
  }
  
  // Party management
  static Future<List<String>> getParty() async {
    return await _getSetting('parties', AppConstants.defaultParties);
  }
  
  static Future<void> addParty(String party) async {
    final parties = await getParty();
    if (!parties.contains(party)) {
      parties.add(party);
      await _saveSetting('parties', parties);
    }
  }
  
  static Future<void> deleteParty(String party) async {
    final parties = await getParty();
    parties.remove(party);
    await _saveSetting('parties', parties);
  }
  
  // Expense/Income Records
  static Future<bool> addExpenseIncomeRecord(ExpenseIncomeRecord record) async {
    try {
      final db = await database;
      await db.insert('expense_income_records', record.toJson());
      return true;
    } catch (e) {
      print('Error adding expense/income record: $e');
      return false;
    }
  }
  
  static Future<List<ExpenseIncomeRecord>> getExpenseIncomeRecords() async {
    try {
      final db = await database;
      final result = await db.query(
        'expense_income_records',
        orderBy: 'created_at DESC',
      );
      
      return result.map((json) => ExpenseIncomeRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error getting expense/income records: $e');
      return [];
    }
  }
  
  // Bank Transactions
  static Future<bool> addBankTransaction(BankTransaction transaction) async {
    try {
      final db = await database;
      await db.insert('bank_transactions', transaction.toJson());
      return true;
    } catch (e) {
      print('Error adding bank transaction: $e');
      return false;
    }
  }
  
  static Future<List<BankTransaction>> getBankTransactions() async {
    try {
      final db = await database;
      final result = await db.query(
        'bank_transactions',
        orderBy: 'date DESC',
      );
      
      return result.map((json) => BankTransaction.fromJson(json)).toList();
    } catch (e) {
      print('Error getting bank transactions: $e');
      return [];
    }
  }
  
  static Future<List<BankTransaction>> getBankTransactionsByBank(String bankName) async {
    try {
      final db = await database;
      final result = await db.query(
        'bank_transactions',
        where: 'bankName = ?',
        whereArgs: [bankName],
        orderBy: 'date DESC',
      );
      
      return result.map((json) => BankTransaction.fromJson(json)).toList();
    } catch (e) {
      print('Error getting bank transactions for $bankName: $e');
      return [];
    }
  }
  
  static Future<bool> deleteBankTransaction(String id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'bank_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting bank transaction: $e');
      return false;
    }
  }
  
  static Future<List<String>> getBanks() async {
    final cashBankOptions = await getCashBank();
    // FIXED: Create a new modifiable list from the filtered result
    return List<String>.from(
      cashBankOptions.where((option) =>
        option.toLowerCase().contains('bank') ||
        option.toLowerCase().contains('wallet')
      )
    );
  }
  
  // Backup functionality
  static Future<String> createBackup() async {
    try {
      final dataPath = getPortableDataPath();
      final dbPath = path.join(dataPath, 'expense_management.db');
      final backupPath = path.join(
        dataPath,
        'backups',
        'backup_${DateTime.now().millisecondsSinceEpoch}.db'
      );
      
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
        return backupPath;
      } else {
        throw Exception('Database file not found');
      }
    } catch (e) {
      print('Error creating backup: $e');
      throw e;
    }
  }
  
  static Future<bool> restoreBackup(String backupPath) async {
    try {
      final dataPath = getPortableDataPath();
      final dbPath = path.join(dataPath, 'expense_management.db');
      
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        // Close current database
        await _database?.close();
        _database = null;
        
        // Replace with backup
        await backupFile.copy(dbPath);
        
        // Reinitialize database
        _database = await _initDatabase();
        return true;
      } else {
        throw Exception('Backup file not found');
      }
    } catch (e) {
      print('Error restoring backup: $e');
      return false;
    }
  }
  
  // Get database info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dataPath = getPortableDataPath();
      final dbPath = path.join(dataPath, 'expense_management.db');
      final dbFile = File(dbPath);
      
      if (await dbFile.exists()) {
        final stat = await dbFile.stat();
        return {
          'path': dbPath,
          'size': stat.size,
          'modified': stat.modified,
          'isPortable': true,
        };
      } else {
        return {'error': 'Database file not found'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}