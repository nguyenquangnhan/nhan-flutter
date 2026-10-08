import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'supabase_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService._init();

  /// Khởi động lắng nghe trạng thái kết nối mạng
  void startListening() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        debugPrint('Phát hiện kết nối mạng! Kích hoạt đồng bộ ngầm lên Supabase...');
        syncPendingExpenses();
      }
    });
  }

  /// Tiến trình đồng bộ các giao dịch đang chờ (pending)
  Future<int> syncPendingExpenses() async {
    if (_isSyncing) return 0;
    if (!SupabaseService.instance.isConfigured) return 0;

    _isSyncing = true;
    int syncedCount = 0;

    try {
      final pendingItems = await DatabaseHelper.instance.getPendingExpenses();
      if (pendingItems.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('Tìm thấy ${pendingItems.length} giao dịch cần đồng bộ.');

      for (final item in pendingItems) {
        String? cloudUrl = item.cloudImageUrl;

        // 1. Nếu có ảnh cục bộ chưa upload, upload lên Supabase Storage
        if (item.localImagePath != null && cloudUrl == null) {
          cloudUrl = await SupabaseService.instance.uploadReceiptImage(
            item.localImagePath!,
            item.id,
          );
        }

        // 2. Đẩy bản ghi lên Supabase Cloud Database
        final updatedItem = item.copyWith(cloudImageUrl: cloudUrl, syncStatus: 'synced');
        final success = await SupabaseService.instance.syncExpense(updatedItem);

        // 3. Nếu thành công, cập nhật trạng thái trong SQLite
        if (success) {
          await DatabaseHelper.instance.markAsSynced(item.id, cloudUrl ?? '');
          syncedCount++;
        }
      }
    } catch (e) {
      debugPrint('Lỗi trong quá trình đồng bộ: $e');
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
