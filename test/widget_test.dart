import 'package:flutter_test/flutter_test.dart';
import 'package:vku_bank_ocr/core/utils/currency_formatter.dart';
import 'package:vku_bank_ocr/services/bank_bill_parser.dart';
import 'package:vku_bank_ocr/models/expense_category.dart';

void main() {
  group('BankBillParser & CurrencyFormatter Unit Tests', () {
    test('Parse VND amounts with comma and dot formats', () {
      expect(CurrencyFormatter.parseAmount('95,000 VND'), 95000.0);
      expect(CurrencyFormatter.parseAmount('150.000 đ'), 150000.0);
      expect(CurrencyFormatter.parseAmount('2,500,000'), 2500000.0);
    });

    test('Parse MB Bank bill text sample correctly', () {
      const sampleText = '''
MB
Chuyển tiền thành công
95,000 VND
13:30 - 05/10/2026
HOANG THI THANH THO
Vietinbank (CTG)
103878753106
NGUYEN QUANG NHAN chuyen tien
Giao dịch được xác nhận bởi MB.
''';
      final bill = BankBillParser.parse(sampleText, 'dummy/path.jpg');
      expect(bill.amount, 95000.0);
      expect(bill.transferContent, contains('NGUYEN QUANG NHAN chuyen tien'));
      expect(bill.bankName, contains('Vietinbank'));
    });

    test('Heuristic category suggestions based on transfer content', () {
      expect(ExpenseCategory.suggestFromContent('Tien an trua bun cha'), ExpenseCategory.food);
      expect(ExpenseCategory.suggestFromContent('Tien phong tro thang 10'), ExpenseCategory.housing);
      expect(ExpenseCategory.suggestFromContent('Do xang xe may'), ExpenseCategory.transport);
      expect(ExpenseCategory.suggestFromContent('Dong tien quy lop clb'), ExpenseCategory.education);
    });
  });
}
