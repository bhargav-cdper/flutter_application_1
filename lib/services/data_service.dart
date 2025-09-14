import '../models/expense_income_record.dart';
import '../models/bank_transaction.dart';
import 'secure_database_service.dart';

class DataService {
  // Cache for dropdown options to provide synchronous access
  static List<String> _cachedJobs = [];
  static List<String> _cachedAccounts = [];
  static List<String> _cachedCashBank = [];
  static List<String> _cachedParties = [];

  // Initialize data - load from secure database
  static Future<void> initializeData() async {
    await SecureDatabaseService.initialize();
    await _loadAllDropdownCache();
  }

  // Load all dropdown data into cache
  static Future<void> _loadAllDropdownCache() async {
    _cachedJobs = await SecureDatabaseService.getDropdownOptions('Job');
    _cachedAccounts = await SecureDatabaseService.getDropdownOptions('Account');
    _cachedCashBank = await SecureDatabaseService.getDropdownOptions('Cash/Bank');
    _cachedParties = await SecureDatabaseService.getDropdownOptions('Party');
  }

  // Synchronous getters for dropdown options (using cache)
  static List<String> getJobs() => List.from(_cachedJobs);
  static List<String> getAccounts() => List.from(_cachedAccounts);
  static List<String> getCashBank() => List.from(_cachedCashBank);
  static List<String> getParties() => List.from(_cachedParties);

  // Async getters for fresh data (when needed)
  static Future<List<String>> getJobsAsync() async {
    _cachedJobs = await SecureDatabaseService.getDropdownOptions('Job');
    return List.from(_cachedJobs);
  }

  static Future<List<String>> getAccountsAsync() async {
    _cachedAccounts = await SecureDatabaseService.getDropdownOptions('Account');
    return List.from(_cachedAccounts);
  }

  static Future<List<String>> getCashBankAsync() async {
    _cachedCashBank = await SecureDatabaseService.getDropdownOptions('Cash/Bank');
    return List.from(_cachedCashBank);
  }

  static Future<List<String>> getPartiesAsync() async {
    _cachedParties = await SecureDatabaseService.getDropdownOptions('Party');
    return List.from(_cachedParties);
  }

  // Expense/Income Record methods
  static Future<void> saveExpenseIncomeRecord(ExpenseIncomeRecord record) async {
    await SecureDatabaseService.saveExpenseIncomeRecord(record);
  }

  static Future<List<ExpenseIncomeRecord>> getExpenseIncomeRecords() async {
    return await SecureDatabaseService.getExpenseIncomeRecords();
  }

  // Bank Transaction methods
  static Future<void> saveBankTransaction(BankTransaction transaction) async {
    await SecureDatabaseService.saveBankTransaction(transaction);
  }

  static Future<List<BankTransaction>> getBankTransactionsByBank(String bankName) async {
    return await SecureDatabaseService.getBankTransactionsByBank(bankName);
  }

  static Future<double> getBankBalance(String bankName) async {
    return await SecureDatabaseService.getBankBalance(bankName);
  }

  static Future<List<String>> getBanksWithTransactions() async {
    return await SecureDatabaseService.getBanksWithTransactions();
  }

  // Add methods for dropdown options
  static Future<void> addJob(String job) async {
    if (!_cachedJobs.contains(job)) {
      await SecureDatabaseService.addDropdownOption('Job', job);
      _cachedJobs.add(job);
    }
  }

  static Future<void> addAccount(String account) async {
    if (!_cachedAccounts.contains(account)) {
      await SecureDatabaseService.addDropdownOption('Account', account);
      _cachedAccounts.add(account);
    }
  }

  static Future<void> addCashBank(String cashBank) async {
    if (!_cachedCashBank.contains(cashBank)) {
      await SecureDatabaseService.addDropdownOption('Cash/Bank', cashBank);
      _cachedCashBank.add(cashBank);
    }
  }

  static Future<void> addParty(String party) async {
    if (!_cachedParties.contains(party)) {
      await SecureDatabaseService.addDropdownOption('Party', party);
      _cachedParties.add(party);
    }
  }

  // Edit methods for dropdown options
  static Future<void> editJob(int index, String newJob) async {
    if (index >= 0 && index < _cachedJobs.length) {
      final oldJob = _cachedJobs[index];
      await SecureDatabaseService.updateDropdownOption('Job', oldJob, newJob);
      _cachedJobs[index] = newJob;
    }
  }

  static Future<void> editAccount(int index, String newAccount) async {
    if (index >= 0 && index < _cachedAccounts.length) {
      final oldAccount = _cachedAccounts[index];
      await SecureDatabaseService.updateDropdownOption('Account', oldAccount, newAccount);
      _cachedAccounts[index] = newAccount;
    }
  }

  static Future<void> editCashBank(int index, String newCashBank) async {
    if (index >= 0 && index < _cachedCashBank.length) {
      final oldCashBank = _cachedCashBank[index];
      await SecureDatabaseService.updateDropdownOption('Cash/Bank', oldCashBank, newCashBank);
      _cachedCashBank[index] = newCashBank;
    }
  }

  static Future<void> editParty(int index, String newParty) async {
    if (index >= 0 && index < _cachedParties.length) {
      final oldParty = _cachedParties[index];
      await SecureDatabaseService.updateDropdownOption('Party', oldParty, newParty);
      _cachedParties[index] = newParty;
    }
  }

  // Remove methods for dropdown options
  static Future<void> removeJob(int index) async {
    if (index >= 0 && index < _cachedJobs.length) {
      final job = _cachedJobs[index];
      await SecureDatabaseService.deleteDropdownOption('Job', job);
      _cachedJobs.removeAt(index);
    }
  }

  static Future<void> removeAccount(int index) async {
    if (index >= 0 && index < _cachedAccounts.length) {
      final account = _cachedAccounts[index];
      await SecureDatabaseService.deleteDropdownOption('Account', account);
      _cachedAccounts.removeAt(index);
    }
  }

  static Future<void> removeCashBank(int index) async {
    if (index >= 0 && index < _cachedCashBank.length) {
      final cashBank = _cachedCashBank[index];
      await SecureDatabaseService.deleteDropdownOption('Cash/Bank', cashBank);
      _cachedCashBank.removeAt(index);
    }
  }

  static Future<void> removeParty(int index) async {
    if (index >= 0 && index < _cachedParties.length) {
      final party = _cachedParties[index];
      await SecureDatabaseService.deleteDropdownOption('Party', party);
      _cachedParties.removeAt(index);
    }
  }

  // Category name management
  static Future<void> saveCategoryName(String categoryKey, String displayName) async {
    await SecureDatabaseService.saveCategoryName(categoryKey, displayName);
  }

  static Future<String?> getCategoryName(String categoryKey) async {
    return await SecureDatabaseService.getCategoryName(categoryKey);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await SecureDatabaseService.clearAllData();
    await _loadAllDropdownCache();
  }
}