class ExpenseModel {
  final int id;
  final int? amount;
  final String? category;
  final DateTime? dateSpended;
  final String? description;

  ExpenseModel(
      {required this.id,
      required this.amount,
      required this.category,
      required this.dateSpended,
      required this.description});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
        id: json['id'],
        amount: json['amount'],
        category: json['category'],
        dateSpended: json['date_spended'] != null
            ? DateTime.parse(json['date_spended'])
            : null,
        description: json['description']);
  }

  @override
  String toString() {
    return 'ExpenseMode(amount: $amount, category: $category, description: $description, dateReceived: $dateSpended)';
  }
}
