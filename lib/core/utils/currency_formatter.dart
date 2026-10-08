import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static final NumberFormat _simpleNumberFormat = NumberFormat('#,###', 'vi_VN');

  /// Định dạng số tiền thành chuỗi VNĐ: ví dụ 95000 -> "95.000 đ"
  static String formatVND(double amount) {
    return _vndFormat.format(amount).trim();
  }

  /// Định dạng chỉ phần số: 95000 -> "95.000"
  static String formatNumberOnly(double amount) {
    return _simpleNumberFormat.format(amount);
  }

  /// Parse chuỗi chứa số tiền thô từ OCR thành double
  /// Hỗ trợ cả 95.000, 95,000, 95000, 95000 VND, 95.000đ
  static double? parseAmount(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      // Loại bỏ các chữ cái (VND, đ, vnđ...), khoảng trắng
      String cleaned = raw.replaceAll(RegExp(r'[^\d,.]'), '').trim();
      if (cleaned.isEmpty) return null;

      // Nếu có cả dấu chấm và phẩy: ví dụ 1,234.56 hoặc 1.234,56
      if (cleaned.contains('.') && cleaned.contains(',')) {
        if (cleaned.lastIndexOf('.') > cleaned.lastIndexOf(',')) {
          // Chuẩn US: 1,234.56 -> bỏ phẩy
          cleaned = cleaned.replaceAll(',', '');
        } else {
          // Chuẩn VN: 1.234,56 -> bỏ chấm, thay phẩy thành chấm
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        }
      } else if (cleaned.contains('.')) {
        // Nếu chỉ có chấm: Trong VNĐ, 95.000 là 95 nghìn (dấu ngăn hàng nghìn)
        // Kiểm tra xem sau dấu chấm có đúng 3 số không
        final parts = cleaned.split('.');
        if (parts.length > 1 && parts.last.length == 3) {
          cleaned = cleaned.replaceAll('.', '');
        }
      } else if (cleaned.contains(',')) {
        // Nếu chỉ có phẩy: Trong format MB/VCB hay ghi 95,000 VND
        final parts = cleaned.split(',');
        if (parts.length > 1 && parts.last.length == 3) {
          cleaned = cleaned.replaceAll(',', '');
        } else {
          cleaned = cleaned.replaceAll(',', '.');
        }
      }

      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
