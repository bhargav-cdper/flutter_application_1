import '../models/expense_income_record.dart';
import '../models/bank_transaction.dart';
import 'secure_database_service.dart';

class DataService {
  static const String _isInitializedKey = 'app_initialized';

  // Initialize default data ONLY on first run - using secure storage only
  static Future<void> initializeDefaultData() async {
    // Check initialization status from secure storage instead of SharedPreferences
    bool isInitialized = await SecureDatabaseService.isAppInitialized();
    
    print("Checking initialization status: $isInitialized");
    
    if (!isInitialized) {
      print("First time run - initializing secure database");
      
      // Initialize secure database with default data
      await SecureDatabaseService.initialize();
      
      // Mark as initialized in secure storage
      await SecureDatabaseService.setAppInitialized(true);
      print("Secure database initialized successfully");
    } else {
      print("App already initialized - using existing secure database");
      // Just initialize the database connection
      await SecureDatabaseService.initialize();
    }
  }

  // Jobs CRUD Operations
  static Future<List<String>> getJobs() async {
    return await SecureDatabaseService.getJobs();
  }

  static Future<bool> addJob(String job) async {
    return await SecureDatabaseService.addJob(job);
  }

  static Future<bool> deleteJob(String job) async {
    return await SecureDatabaseService.deleteJob(job);
  }

  // Accounts CRUD Operations
  static Future<List<String>> getAccounts() async {
    return await SecureDatabaseService.getAccounts();
  }

  static Future<bool> addAccount(String account) async {
    return await SecureDatabaseService.addAccount(account);
  }

  static Future<bool> deleteAccount(String account) async {
    return await SecureDatabaseService.deleteAccount(account);
  }

  // Cash/Bank CRUD Operations
  static Future<List<String>> getCashBank() async {
    return await SecureDatabaseService.getCashBank();
  }

  static Future<bool> addCashBank(String cashBank) async {
    return await SecureDatabaseService.addCashBank(cashBank);
  }

  static Future<bool> deleteCashBank(String cashBank) async {
    return await SecureDatabaseService.deleteCashBank(cashBank);
  }

  // Party CRUD Operations
  static Future<List<String>> getParty() async {
    return await SecureDatabaseService.getParty();
  }

  static Future<bool> addParty(String party) async {
    return await SecureDatabaseService.addParty(party);
  }

  static Future<bool> deleteParty(String party) async {
    return await SecureDatabaseService.deleteParty(party);
  }

  // Expense Income Records CRUD
  static Future<List<ExpenseIncomeRecord>> getExpenseIncomeRecords() async {
    return await SecureDatabaseService.getExpenseIncomeRecords();
  }

  static Future<bool> addExpenseIncomeRecord(ExpenseIncomeRecord record) async {
    return await SecureDatabaseService.addExpenseIncomeRecord(record);
  }

  static Future<bool> deleteExpenseIncomeRecord(String id) async {
    return await SecureDatabaseService.deleteExpenseIncomeRecord(id);
  }

  // Bank Transactions CRUD
  static Future<List<BankTransaction>> getBankTransactions() async {
    return await SecureDatabaseService.getBankTransactions();
  }

  static Future<bool> addBankTransaction(BankTransaction transaction) async {
    return await SecureDatabaseService.addBankTransaction(transaction);
  }

  static Future<bool> deleteBankTransaction(String id) async {
    return await SecureDatabaseService.deleteBankTransaction(id);
  }

  // Utility Methods - Now fully secure
  static Future<bool> isAppInitialized() async {
    return await SecureDatabaseService.isAppInitialized();
  }

  static Future<void> resetInitialization() async {
    await SecureDatabaseService.setAppInitialized(false);
    await SecureDatabaseService.clearAllData();
    print("Initialization reset - all data cleared from secure storage");
  }

  static Future<void> clearAllData() async {
    await SecureDatabaseService.clearAllData();
    await SecureDatabaseService.setAppInitialized(false);
    print("All data cleared from secure storage");
  }

  // Debug method
  static Future<void> debugPrintAllData() async {
    print("=== DEBUG: All Stored Secure Data ===");
    print("Is Initialized: ${await isAppInitialized()}");
    print("Jobs: ${await getJobs()}");
    print("Accounts: ${await getAccounts()}");
    print("Cash/Bank: ${await getCashBank()}");
    print("Party: ${await getParty()}");
    
    final expenseRecords = await getExpenseIncomeRecords();
    print("Expense/Income Records: ${expenseRecords.length} items");
    
    final bankTransactions = await getBankTransactions();
    print("Bank Transactions: ${bankTransactions.length} items");
    print("=====================================");
  }

  // Backward compatibility methods (for existing code that uses index-based deletion)
  static Future<bool> deleteExpenseIncomeRecordByIndex(int index) async {
    final records = await getExpenseIncomeRecords();
    if (index >= 0 && index < records.length) {
      return await deleteExpenseIncomeRecord(records[index].id);
    }
    return false;
  }

  static Future<bool> deleteBankTransactionByIndex(int index) async {
    final transactions = await getBankTransactions();
    if (index >= 0 && index < transactions.length) {
      return await deleteBankTransaction(transactions[index].id);
    }
    return false;
  }
}