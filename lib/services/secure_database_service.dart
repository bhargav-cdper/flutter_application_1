import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/expense_income_record.dart';
import '../models/bank_transaction.dart';

class SecureDatabaseService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
  );

  // Storage Keys
  static const String _appInitializedKey = 'app_initialized';
  static const String _jobsKey = 'secure_jobs';
  static const String _accountsKey = 'secure_accounts';
  static const String _cashBankKey = 'secure_cash_bank';
  static const String _partyKey = 'secure_party';
  static const String _expenseRecordsKey = 'secure_expense_records';
  static const String _bankTransactionsKey = 'secure_bank_transactions';

  // Initialize the database with default data
  static Future<void> initialize() async {
    try {
      bool isInitialized = await isAppInitialized();
      
      if (!isInitialized) {
        print("Initializing secure database with default data...");
        await _loadDefaultData();
        await setAppInitialized(true);
        print("Secure database initialized successfully");
      } else {
        print("Secure database already initialized");
      }
    } catch (e) {
      print("Error initializing secure database: $e");
    }
  }

  // Load default data
  static Future<void> _loadDefaultData() async {
    // Default Jobs
    List<String> defaultJobs = [
      'Software Development',
      'Marketing',
      'Sales',
      'HR Management',
      'Accounting',
      'Design',
      'Consulting'
    ];

    // Default Accounts
    List<String> defaultAccounts = [
      'Business Account',
      'Personal Account',
      'Savings Account',
      'Investment Account',
      'Expense Account'
    ];

    // Default Cash/Bank options
    List<String> defaultCashBank = [
      'Cash',
      'SBI Bank',
      'HDFC Bank',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Bank',
      'PayTM Wallet',
      'PhonePe Wallet'
    ];

    // Default Parties
    List<String> defaultParties = [
      'Client A',
      'Client B',
      'Vendor 1',
      'Vendor 2',
      'Employee 1',
      'Employee 2',
      'Contractor'
    ];

    // Save default data
    await _writeSecureList(_jobsKey, defaultJobs);
    await _writeSecureList(_accountsKey, defaultAccounts);
    await _writeSecureList(_cashBankKey, defaultCashBank);
    await _writeSecureList(_partyKey, defaultParties);
    
    // Initialize empty records
    await _secureStorage.write(key: _expenseRecordsKey, value: jsonEncode([]));
    await _secureStorage.write(key: _bankTransactionsKey, value: jsonEncode([]));
  }

  // App Initialization Methods
  static Future<bool> isAppInitialized() async {
    try {
      String? value = await _secureStorage.read(key: _appInitializedKey);
      return value == 'true';
    } catch (e) {
      print('Error checking app initialization: $e');
      return false;
    }
  }

  static Future<void> setAppInitialized(bool initialized) async {
    try {
      await _secureStorage.write(
        key: _appInitializedKey, 
        value: initialized.toString()
      );
    } catch (e) {
      print('Error setting app initialization: $e');
    }
  }

  // Helper Methods for List Operations
  static Future<List<String>> _readSecureList(String key) async {
    try {
      String? data = await _secureStorage.read(key: key);
      if (data != null && data.isNotEmpty) {
        List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error reading secure list for key $key: $e');
      return [];
    }
  }

  static Future<void> _writeSecureList(String key, List<String> list) async {
    try {
      await _secureStorage.write(key: key, value: jsonEncode(list));
    } catch (e) {
      print('Error writing secure list for key $key: $e');
    }
  }

  // Jobs CRUD Operations
  static Future<List<String>> getJobs() async {
    return await _readSecureList(_jobsKey);
  }

  static Future<bool> addJob(String job) async {
    try {
      List<String> jobs = await getJobs();
      if (!jobs.contains(job)) {
        jobs.add(job);
        await _writeSecureList(_jobsKey, jobs);
        return true;
      }
      return false; // Already exists
    } catch (e) {
      print('Error adding job: $e');
      return false;
    }
  }

  static Future<bool> deleteJob(String job) async {
    try {
      List<String> jobs = await getJobs();
      if (jobs.contains(job)) {
        jobs.remove(job);
        await _writeSecureList(_jobsKey, jobs);
        return true;
      }
      return false; // Not found
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }

  // Accounts CRUD Operations
  static Future<List<String>> getAccounts() async {
    return await _readSecureList(_accountsKey);
  }

  static Future<bool> addAccount(String account) async {
    try {
      List<String> accounts = await getAccounts();
      if (!accounts.contains(account)) {
        accounts.add(account);
        await _writeSecureList(_accountsKey, accounts);
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding account: $e');
      return false;
    }
  }

  static Future<bool> deleteAccount(String account) async {
    try {
      List<String> accounts = await getAccounts();
      if (accounts.contains(account)) {
        accounts.remove(account);
        await _writeSecureList(_accountsKey, accounts);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Cash/Bank CRUD Operations
  static Future<List<String>> getCashBank() async {
    return await _readSecureList(_cashBankKey);
  }

  static Future<bool> addCashBank(String cashBank) async {
    try {
      List<String> cashBankList = await getCashBank();
      if (!cashBankList.contains(cashBank)) {
        cashBankList.add(cashBank);
        await _writeSecureList(_cashBankKey, cashBankList);
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding cash/bank: $e');
      return false;
    }
  }

  static Future<bool> deleteCashBank(String cashBank) async {
    try {
      List<String> cashBankList = await getCashBank();
      if (cashBankList.contains(cashBank)) {
        cashBankList.remove(cashBank);
        await _writeSecureList(_cashBankKey, cashBankList);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting cash/bank: $e');
      return false;
    }
  }

  // Party CRUD Operations
  static Future<List<String>> getParty() async {
    return await _readSecureList(_partyKey);
  }

  static Future<bool> addParty(String party) async {
    try {
      List<String> parties = await getParty();
      if (!parties.contains(party)) {
        parties.add(party);
        await _writeSecureList(_partyKey, parties);
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding party: $e');
      return false;
    }
  }

  static Future<bool> deleteParty(String party) async {
    try {
      List<String> parties = await getParty();
      if (parties.contains(party)) {
        parties.remove(party);
        await _writeSecureList(_partyKey, parties);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting party: $e');
      return false;
    }
  }

  // Expense Income Records CRUD
  static Future<List<ExpenseIncomeRecord>> getExpenseIncomeRecords() async {
    try {
      String? data = await _secureStorage.read(key: _expenseRecordsKey);
      if (data != null && data.isNotEmpty) {
        List<dynamic> decoded = jsonDecode(data);
        return decoded.map((item) => ExpenseIncomeRecord.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting expense income records: $e');
      return [];
    }
  }

  static Future<bool> addExpenseIncomeRecord(ExpenseIncomeRecord record) async {
    try {
      List<ExpenseIncomeRecord> records = await getExpenseIncomeRecords();
      records.add(record);
      
      List<Map<String, dynamic>> jsonList = records.map((r) => r.toJson()).toList();
      await _secureStorage.write(key: _expenseRecordsKey, value: jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error adding expense income record: $e');
      return false;
    }
  }

  static Future<bool> deleteExpenseIncomeRecord(String id) async {
    try {
      List<ExpenseIncomeRecord> records = await getExpenseIncomeRecords();
      records.removeWhere((record) => record.id == id);
      
      List<Map<String, dynamic>> jsonList = records.map((r) => r.toJson()).toList();
      await _secureStorage.write(key: _expenseRecordsKey, value: jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error deleting expense income record: $e');
      return false;
    }
  }

  // Bank Transactions CRUD
  static Future<List<BankTransaction>> getBankTransactions() async {
    try {
      String? data = await _secureStorage.read(key: _bankTransactionsKey);
      if (data != null && data.isNotEmpty) {
        List<dynamic> decoded = jsonDecode(data);
        return decoded.map((item) => BankTransaction.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting bank transactions: $e');
      return [];
    }
  }

  static Future<bool> addBankTransaction(BankTransaction transaction) async {
    try {
      List<BankTransaction> transactions = await getBankTransactions();
      transactions.add(transaction);
      
      List<Map<String, dynamic>> jsonList = transactions.map((t) => t.toJson()).toList();
      await _secureStorage.write(key: _bankTransactionsKey, value: jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error adding bank transaction: $e');
      return false;
    }
  }

  static Future<bool> deleteBankTransaction(String id) async {
    try {
      List<BankTransaction> transactions = await getBankTransactions();
      transactions.removeWhere((transaction) => transaction.id == id);
      
      List<Map<String, dynamic>> jsonList = transactions.map((t) => t.toJson()).toList();
      await _secureStorage.write(key: _bankTransactionsKey, value: jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error deleting bank transaction: $e');
      return false;
    }
  }

  // Utility Methods
  static Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
      print('All secure data cleared');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Debug method to print all stored data
  static Future<void> debugPrintData() async {
    print("=== Secure Database Debug Info ===");
    print("App Initialized: ${await isAppInitialized()}");
    print("Jobs: ${await getJobs()}");
    print("Accounts: ${await getAccounts()}");
    print("Cash/Bank: ${await getCashBank()}");
    print("Parties: ${await getParty()}");
    
    List<ExpenseIncomeRecord> expenseRecords = await getExpenseIncomeRecords();
    print("Expense Records Count: ${expenseRecords.length}");
    
    List<BankTransaction> bankTransactions = await getBankTransactions();
    print("Bank Transactions Count: ${bankTransactions.length}");
    print("==================================");
  }
}