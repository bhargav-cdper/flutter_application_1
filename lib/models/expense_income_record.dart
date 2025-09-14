class ExpenseIncomeRecord {
  final String id;
  final String cashBank;
  final DateTime date;
  final String job;
  final String details;
  final String unit;
  final double qty;
  final double rate;
  final double credit;
  final double debit;
  final double netAmount;
  final String account;
  final String staffPersonalParty;

  ExpenseIncomeRecord({
    required this.id,
    required this.cashBank,
    required this.date,
    required this.job,
    required this.details,
    required this.unit,
    required this.qty,
    required this.rate,
    required this.credit,
    required this.debit,
    required this.netAmount,
    required this.account,
    required this.staffPersonalParty,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashBank': cashBank,
      'date': date.toIso8601String(),
      'job': job,
      'details': details,
      'unit': unit,
      'qty': qty,
      'rate': rate,
      'credit': credit,
      'debit': debit,
      'netAmount': netAmount,
      'account': account,
      'staffPersonalParty': staffPersonalParty,
    };
  }

  // Create from JSON
  factory ExpenseIncomeRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseIncomeRecord(
      id: json['id'],
      cashBank: json['cashBank'],
      date: DateTime.parse(json['date']),
      job: json['job'],
      details: json['details'],
      unit: json['unit'],
      qty: json['qty']?.toDouble() ?? 0.0,
      rate: json['rate']?.toDouble() ?? 0.0,
      credit: json['credit']?.toDouble() ?? 0.0,
      debit: json['debit']?.toDouble() ?? 0.0,
      netAmount: json['netAmount']?.toDouble() ?? 0.0,
      account: json['account'],
      staffPersonalParty: json['staffPersonalParty'],
    );
  }
}