class ExpenseIncomeRecord {
  final String id;
  final String cashBank;
  final String date;
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
    String? id,
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
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashBank': cashBank,
      'date': date,
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

  factory ExpenseIncomeRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseIncomeRecord(
      id: json['id']?.toString(),
      cashBank: json['cashBank']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      job: json['job']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      account: json['account']?.toString() ?? '',
      staffPersonalParty: json['staffPersonalParty']?.toString() ?? '',
    );
  }

  ExpenseIncomeRecord copyWith({
    String? id,
    String? cashBank,
    String? date,
    String? job,
    String? details,
    String? unit,
    double? qty,
    double? rate,
    double? credit,
    double? debit,
    double? netAmount,
    String? account,
    String? staffPersonalParty,
  }) {
    return ExpenseIncomeRecord(
      id: id ?? this.id,
      cashBank: cashBank ?? this.cashBank,
      date: date ?? this.date,
      job: job ?? this.job,
      details: details ?? this.details,
      unit: unit ?? this.unit,
      qty: qty ?? this.qty,
      rate: rate ?? this.rate,
      credit: credit ?? this.credit,
      debit: debit ?? this.debit,
      netAmount: netAmount ?? this.netAmount,
      account: account ?? this.account,
      staffPersonalParty: staffPersonalParty ?? this.staffPersonalParty,
    );
  }

  @override
  String toString() {
    return 'ExpenseIncomeRecord(id: $id, cashBank: $cashBank, date: $date, job: $job, details: $details, unit: $unit, qty: $qty, rate: $rate, credit: $credit, debit: $debit, netAmount: $netAmount, account: $account, staffPersonalParty: $staffPersonalParty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseIncomeRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}