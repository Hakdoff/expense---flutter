// import 'package:flutter/material.dart';
// import 'package:flutter_expense_tracker/model/bills_model.dart';
// import 'package:intl/intl.dart';

// class EditBills extends StatefulWidget {
//   final BillsModel bills;
//   const EditBills({super.key, required this.bills});

//   @override
//   State<EditBills> createState() => _EditBillsState();
// }

// class _EditBillsState extends State<EditBills> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _amountController;
//   late TextEditingController _itemController;
//   late TextEditingController _categoryController;

//   @override
//   void initState() {
//     super.initState();
//     _amountController =
//         TextEditingController(text: widget.bills.amount.toString());
//     _itemController = TextEditingController(text: widget.bills.item);
//     _categoryController = TextEditingController(text: widget.bills.category);
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _itemController.dispose();
//     _categoryController.dispose();
//     super.dispose();
//   }

//   Future<void> _editBills() async {
//     try {
//   if (_formKey.currentState!.validate()) {
//     final result = await editBill
//   }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
