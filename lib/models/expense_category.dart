import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  housing,
  transport,
  shopping,
  education,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Ăn uống';
      case ExpenseCategory.housing:
        return 'Tiện ích / Tiền trọ';
      case ExpenseCategory.transport:
        return 'Di chuyển';
      case ExpenseCategory.shopping:
        return 'Mua sắm';
      case ExpenseCategory.education:
        return 'Học tập / Quỹ CLB';
      case ExpenseCategory.other:
        return 'Khác';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.housing:
        return Icons.home_work_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_bike_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.education:
        return Icons.school_outlined;
      case ExpenseCategory.other:
        return Icons.category_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFE65100); // Cam đậm
      case ExpenseCategory.housing:
        return const Color(0xFF00897B); // Xanh mòng két
      case ExpenseCategory.transport:
        return const Color(0xFF1E88E5); // Xanh dương
      case ExpenseCategory.shopping:
        return const Color(0xFF8E24AA); // Tím
      case ExpenseCategory.education:
        return const Color(0xFF2C4570); // VKU Navy
      case ExpenseCategory.other:
        return const Color(0xFF757575); // Xám
    }
  }

  /// Danh sách từ khóa (tách theo từ nguyên vẹn để tránh trùng chuỗi con như "an" trong "thang")
  List<String> get heuristicKeywords {
    switch (this) {
      case ExpenseCategory.food:
        return ['ăn', 'an', 'cơm', 'com', 'cafe', 'cà phê', 'ca phe', 'trà sữa', 'tra sua', 'food', 'lẩu', 'lau', 'nước', 'đồ ăn', 'do an', 'pizza', 'bún', 'bun', 'phở', 'pho', 'bbq', 'bánh', 'banh'];
      case ExpenseCategory.housing:
        return ['trọ', 'tro', 'phòng', 'phong', 'điện', 'dien', 'nước', 'wifi', 'internet', 'nhà', 'nha', 'chung cư', 'mặt bằng', 'mat bang'];
      case ExpenseCategory.transport:
        return ['xăng', 'xang', 'grab', 'be', 'gojek', 'xe', 'vé xe', 've xe', 'bus', 'gửi xe', 'gui xe', 'taxi'];
      case ExpenseCategory.shopping:
        return ['shopee', 'lazada', 'tiki', 'tiktok', 'shop', 'áo', 'ao', 'quần', 'quan', 'giày', 'giay', 'mua', 'đơn hàng', 'don hang'];
      case ExpenseCategory.education:
        return ['sách', 'sach', 'học phí', 'hoc phi', 'tài liệu', 'tai lieu', 'in ấn', 'in an', 'học', 'hoc', 'quỹ', 'quy', 'lớp', 'lop', 'clb', 'đóng quỹ', 'dong quy'];
      case ExpenseCategory.other:
        return [];
    }
  }

  /// Suy luận danh mục chính xác bằng cách so khớp từ nguyên vẹn (word boundary)
  static ExpenseCategory suggestFromContent(String content) {
    final lower = content.toLowerCase();
    // Tách các từ riêng biệt
    final words = lower.split(RegExp(r'[\s,.\-_/]+')).toSet();

    for (final category in ExpenseCategory.values) {
      for (final keyword in category.heuristicKeywords) {
        // Nếu keyword có nhiều từ (ví dụ "tra sua", "phong tro", "tien an")
        if (keyword.contains(' ')) {
          if (lower.contains(keyword)) {
            return category;
          }
        } else {
          // Keyword đơn: so khớp chính xác từng từ để không nhầm "an" trong "thang"
          if (words.contains(keyword)) {
            return category;
          }
        }
      }
    }
    return ExpenseCategory.other;
  }

  static ExpenseCategory fromString(String? value) {
    if (value == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
