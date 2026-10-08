import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_item.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  // Cấu hình Supabase
  static const String supabaseUrl = 'https://crftkbekipkwmnxwbqhe.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyZnRrYmVraXBrd21ueHdicWhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE0MjYwODAsImV4cCI6MjEwNzAwMjA4MH0.AZFbc946l6yenp_Iu4_SHOMF0cEuYy8AzGRw--Iw0t4';
  static const String storageBucket = 'transfer_receipts';

  bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('your-project') &&
      supabaseAnonKey.isNotEmpty;

  SupabaseClient? get client {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Khởi tạo Supabase SDK trong hàm main()
  static Future<void> initialize() async {
    if (instance.isConfigured) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey, // ignore: deprecated_member_use
        );
        debugPrint('Khởi tạo Supabase thành công!');
      } catch (e) {
        debugPrint('Không thể khởi tạo Supabase: $e');
      }
    } else {
      debugPrint('Chưa cấu hình Supabase URL và AnonKey. Đang chạy chế độ Local-Only.');
    }
  }

  /// Tải ảnh chụp màn hình chuyển khoản lên Supabase Storage
  Future<String?> uploadReceiptImage(String localPath, String expenseId) async {
    final client = this.client;
    if (client == null) return null;

    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final fileExt = localPath.split('.').last;
      final fileName = 'receipt_$expenseId.$fileExt';

      await client.storage.from(storageBucket).upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = client.storage.from(storageBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Lỗi upload ảnh lên Supabase Storage: $e');
      return null;
    }
  }

  /// Đồng bộ bản ghi giao dịch lên bảng expenses trên Supabase
  Future<bool> syncExpense(ExpenseItem item) async {
    final client = this.client;
    if (client == null) return false;

    try {
      await client.from('expenses').upsert(item.toSupabaseMap());
      return true;
    } catch (e) {
      debugPrint('Lỗi sync bản ghi lên Supabase: $e');
      return false;
    }
  }
}
