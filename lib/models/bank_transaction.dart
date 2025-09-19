class BankTransaction {
  String id;
  String date; // Keeping as String to match your existing structure
  String description;
  double credit;
  double debit;
  double netBalance;
  String party;
  String salaryLoanMonth;
  String bankName; // Added bankName field

  BankTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.credit,
    required this.debit,
    required this.netBalance,
    required this.party,
    required this.salaryLoanMonth,
    required this.bankName, // Added bankName parameter
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'credit': credit,
      'debit': debit,
      'netBalance': netBalance,
      'party': party,
      'salaryLoanMonth': salaryLoanMonth,
      'bankName': bankName,
    };
  }

  // Create from JSON
  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      credit: (json['credit'] ?? 0.0).toDouble(),
      debit: (json['debit'] ?? 0.0).toDouble(),
      netBalance: (json['netBalance'] ?? 0.0).toDouble(),
      party: json['party'] ?? '',
      salaryLoanMonth: json['salaryLoanMonth'] ?? '',
      bankName: json['bankName'] ?? '', // Handle bankName from JSON
    );
  }

  // Helper method to get date as DateTime object
  DateTime get dateAsDateTime {
    try {
      // Try to parse the date string (assuming format: dd/MM/yyyy)
      List<String> parts = date.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now(); // Fallback to current date
  }

  // Helper method to format date string
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}