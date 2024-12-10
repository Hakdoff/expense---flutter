class IncomeModel {
  final int id;
  final int? amount;
  final String? description;
  final String? category;
  final DateTime? dateReceived;

  IncomeModel(
      {required this.id,
      required this.amount,
      required this.description,
      required this.category,
      required this.dateReceived});

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'],
      amount: json['amount'],
      description: json['description'],
      category: json['category'],
      dateReceived: json['date_received'] != null
          ? DateTime.parse(json['date_received'])
          : null,
    );
  }

  @override
  String toString() {
    return 'IncomeModel(amount: $amount, category: $category, description: $description, dateReceived: $dateReceived)';
  }
}
