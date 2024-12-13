class ExpenseModel {
  final int id;
  final int? amount;
  final String? category;
  final DateTime? date;
  final String? description;
  final String type = 'Income';

  ExpenseModel(
      {required this.id,
      required this.amount,
      required this.category,
      required this.date,
      required this.description});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
        id: json['id'],
        amount: json['amount'],
        category: json['category'],
        date: json['date_spended'] != null
            ? DateTime.parse(json['date_spended'])
            : null,
        description: json['description']);
  }

  @override
  String toString() {
    return 'ExpenseMode(amount: $amount, category: $category, description: $description, date: $date)';
  }
}
