class IncomeModel {
  final int id;
  final int? amount;
  final String? description;
  final String? category;
  final DateTime? date;
  final String type = 'Expense';

  IncomeModel(
      {required this.id,
      required this.amount,
      required this.description,
      required this.category,
      required this.date});

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'],
      amount: json['amount'],
      description: json['description'],
      category: json['category'],
      date: json['date_received'] != null
          ? DateTime.parse(json['date_received'])
          : null,
    );
  }

  @override
  String toString() {
    return 'IncomeModel(amount: $amount, category: $category, description: $description, date: $date)';
  }
}
