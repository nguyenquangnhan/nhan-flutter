import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_item.dart';
import '../models/expense_category.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

class ExpenseListNotifier extends AsyncNotifier<List<ExpenseItem>> {
  @override
  Future<List<ExpenseItem>> build() async {
    return await _loadFromDatabase();
  }

  Future<List<ExpenseItem>> _loadFromDatabase() async {
    return await DatabaseHelper.instance.getAllExpenses();
  }

  Future<void> addExpense(ExpenseItem item) async {
    // 1. Lưu vào SQLite cục bộ trước
    await DatabaseHelper.instance.insertExpense(item);

    // 2. Cập nhật State tức thì (Zero Latency)
    final currentList = state.value ?? [];
    state = AsyncData([item, ...currentList]);

    // 3. Kích hoạt đồng bộ ngầm nếu có mạng
    SyncService.instance.syncPendingExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    final currentList = state.value ?? [];
    state = AsyncData(currentList.where((e) => e.id != id).toList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadFromDatabase());
    await SyncService.instance.syncPendingExpenses();
  }
}

final expenseListProvider =
    AsyncNotifierProvider<ExpenseListNotifier, List<ExpenseItem>>(
  ExpenseListNotifier.new,
);

/// Provider tính tổng tiền chi tiêu
final totalExpenseProvider = Provider<double>((ref) {
  final expensesAsync = ref.watch(expenseListProvider);
  return expensesAsync.maybeWhen(
    data: (items) => items.fold(0.0, (sum, item) => sum + item.amount),
    orElse: () => 0.0,
  );
});

/// Dữ liệu phục vụ vẽ Donut Chart theo danh mục
class CategoryChartData {
  final ExpenseCategory category;
  final double amount;
  final double percentage; // 0.0 -> 1.0

  CategoryChartData({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

final categoryBreakdownProvider = Provider<List<CategoryChartData>>((ref) {
  final expensesAsync = ref.watch(expenseListProvider);
  return expensesAsync.maybeWhen(
    data: (items) {
      if (items.isEmpty) return [];

      final total = items.fold(0.0, (sum, item) => sum + item.amount);
      if (total == 0) return [];

      final Map<ExpenseCategory, double> map = {};
      for (final item in items) {
        map[item.category] = (map[item.category] ?? 0.0) + item.amount;
      }

      return map.entries.map((entry) {
        return CategoryChartData(
          category: entry.key,
          amount: entry.value,
          percentage: entry.value / total,
        );
      }).toList();
    },
    orElse: () => [],
  );
});

/// Dữ liệu thống kê 7 ngày gần nhất cho Bar Chart
class DayExpenseData {
  final String dayLabel;
  final double amount;
  final DateTime date;

  DayExpenseData({
    required this.dayLabel,
    required this.amount,
    required this.date,
  });
}

final weeklyExpenseProvider = Provider<List<DayExpenseData>>((ref) {
  final expensesAsync = ref.watch(expenseListProvider);
  return expensesAsync.maybeWhen(
    data: (items) {
      final now = DateTime.now();
      final List<DayExpenseData> result = [];

      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final dayTotal = items.where((item) {
          return item.transactionTime.year == targetDate.year &&
              item.transactionTime.month == targetDate.month &&
              item.transactionTime.day == targetDate.day;
        }).fold(0.0, (sum, item) => sum + item.amount);

        final labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        final label = labels[targetDate.weekday % 7];

        result.add(DayExpenseData(
          dayLabel: label,
          amount: dayTotal,
          date: targetDate,
        ));
      }

      return result;
    },
    orElse: () => [],
  );
});
