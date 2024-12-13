class BillsModel {
  final int id;
  final int? amount;
  final String? category;
  final String? item;

  BillsModel({
    required this.id,
    this.amount,
    this.category,
    this.item,
  });

  factory BillsModel.fromJson(Map<String, dynamic> json) {
    return BillsModel(
      id: json['id'] ?? 0,
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? '',
      item: json['item']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'BillsModel (amount: $amount, category: $category, item: $item)';
  }
}
