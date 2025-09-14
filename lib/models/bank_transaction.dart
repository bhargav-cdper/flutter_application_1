class BankTransaction {
  final String id;
  final DateTime date;
  final String description;
  final double credit;
  final double debit;
  final double netBalance;
  final String party;
  final String salaryLoanMonth;
  final String bankName;

  BankTransaction({
    required this.id,
    required this.date,
    required this.description,
    required this.credit,
    required this.debit,
    required this.netBalance,
    required this.party,
    required this.salaryLoanMonth,
    required this.bankName,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
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
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      credit: json['credit']?.toDouble() ?? 0.0,
      debit: json['debit']?.toDouble() ?? 0.0,
      netBalance: json['netBalance']?.toDouble() ?? 0.0,
      party: json['party'],
      salaryLoanMonth: json['salaryLoanMonth'],
      bankName: json['bankName'],
    );
  }
}