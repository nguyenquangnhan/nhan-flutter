import '../models/expense_category.dart';
import '../models/parsed_bank_bill.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class BankBillParser {
  /// Bóc tách toàn diện thông tin từ chuỗi OCR ảnh chuyển khoản ngân hàng
  static ParsedBankBill parse(String rawText, String imagePath) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    double? extractedAmount;
    String? rawAmountStr;
    String? extractedContent;
    String? extractedRecipient;
    String? extractedBank;
    DateTime? extractedTime;

    // 1. Regex bóc tách Số tiền:
    final amountWithCurrencyRegex = RegExp(
      r'([\d]{1,3}(?:[.,]\d{3})*(?:\.\d{2})?)\s*(?:VND|VNĐ|đ|dong)',
      caseSensitive: false,
    );
    final standaloneNumberRegex = RegExp(r'^[\d]{1,3}(?:[.,]\d{3})+$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Tìm dòng chứa số tiền kèm đơn vị tiền tệ
      final matchCurrency = amountWithCurrencyRegex.firstMatch(line);
      if (matchCurrency != null && extractedAmount == null) {
        rawAmountStr = matchCurrency.group(0);
        extractedAmount = CurrencyFormatter.parseAmount(matchCurrency.group(1));
      }

      // Nếu dòng trước là "Số tiền" hoặc "Chuyển tiền thành công" và dòng sau là số
      if (extractedAmount == null) {
        final lower = line.toLowerCase();
        if (lower.contains('thanh cong') || lower.contains('so tien') || lower.contains('amount')) {
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            final matchNext = amountWithCurrencyRegex.firstMatch(nextLine);
            if (matchNext != null) {
              rawAmountStr = matchNext.group(0);
              extractedAmount = CurrencyFormatter.parseAmount(matchNext.group(1));
            } else if (standaloneNumberRegex.hasMatch(nextLine)) {
              rawAmountStr = nextLine;
              extractedAmount = CurrencyFormatter.parseAmount(nextLine);
            }
          }
        }
      }

      // 2. Regex bóc tách Thời gian giao dịch:
      final timeRegex = RegExp(r'\b\d{1,2}:\d{2}\s*[-–]\s*\d{1,2}/\d{1,2}/\d{4}\b');
      final dateRegex = RegExp(r'\b\d{1,2}/\d{1,2}/\d{4}\b');

      if (extractedTime == null) {
        final timeMatch = timeRegex.firstMatch(line);
        if (timeMatch != null) {
          extractedTime = DateFormatter.parseDateTime(timeMatch.group(0));
        } else {
          final dateMatch = dateRegex.firstMatch(line);
          if (dateMatch != null) {
            extractedTime = DateFormatter.parseDateTime(dateMatch.group(0));
          }
        }
      }

      // 3. Regex bóc tách Ngân hàng nhận:
      final bankRegex = RegExp(
        r'\b(Vietinbank|Vietcombank|Techcombank|BIDV|Agribank|ACB|VPBank|TPBank|Sacombank|VIB|MB Bank|MoMo|ZaloPay)\b|^MB$',
        caseSensitive: false,
      );
      final lowerLine = line.toLowerCase();
      final isFooterNotice = lowerLine.contains('xác nhận') ||
          lowerLine.contains('xac nhan') ||
          lowerLine.contains('vui lòng') ||
          lowerLine.contains('vui long');

      if (bankRegex.hasMatch(line) && !isFooterNotice) {
        if (extractedBank == null || (line != 'MB' && extractedBank == 'MB')) {
          extractedBank = line;
        }
      }

      // 4. Regex bóc tách Nội dung chuyển khoản:
      final lower = line.toLowerCase();
      if (extractedContent == null) {
        if (lower.contains('chuyen tien') ||
            lower.contains('noi dung') ||
            lower.contains('loi nhan') ||
            lower.contains('thanh toan')) {
          // Bỏ qua dòng tiêu đề "Chuyển tiền thành công"
          if (!lower.contains('thanh cong')) {
            extractedContent = line;
          }
        }
      }
    }

    // Nếu không tìm thấy nội dung có từ khóa, tìm dòng chữ có khả năng là nội dung
    if (extractedContent == null) {
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (!lower.contains('thanh cong') &&
            !lower.contains('vnd') &&
            !lower.contains('xac nhan') &&
            !RegExp(r'^\d+$').hasMatch(line) &&
            line.length > 5) {
          if (line.toUpperCase() == line || lower.contains('tien')) {
            extractedContent = line;
            break;
          }
        }
      }
    }

    // Gợi ý danh mục dựa vào nội dung chuyển khoản
    final suggestedCategory = extractedContent != null
        ? ExpenseCategory.suggestFromContent(extractedContent)
        : ExpenseCategory.other;

    return ParsedBankBill(
      amount: extractedAmount,
      rawAmountString: rawAmountStr,
      transferContent: extractedContent ?? 'Chuyển tiền',
      recipientName: extractedRecipient,
      bankName: extractedBank,
      transactionTime: extractedTime ?? DateTime.now(),
      suggestedCategory: suggestedCategory,
      imagePath: imagePath,
      rawOcrText: rawText,
    );
  }
}
