import 'expense_category.dart';

class ParsedBankBill {
  final double? amount;
  final String? rawAmountString;
  final String? transferContent;
  final String? recipientName;
  final String? bankName;
  final DateTime? transactionTime;
  final ExpenseCategory suggestedCategory;
  final String imagePath;
  final String rawOcrText;

  const ParsedBankBill({
    this.amount,
    this.rawAmountString,
    this.transferContent,
    this.recipientName,
    this.bankName,
    this.transactionTime,
    this.suggestedCategory = ExpenseCategory.other,
    required this.imagePath,
    required this.rawOcrText,
  });
}
