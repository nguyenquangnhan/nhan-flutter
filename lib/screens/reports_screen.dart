import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/expense_notifier.dart';
import '../core/utils/currency_formatter.dart';
import '../widgets/charts/animated_donut_chart.dart';
import '../widgets/charts/weekly_bar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalAmount = ref.watch(totalExpenseProvider);
    final categoryData = ref.watch(categoryBreakdownProvider);
    final weeklyData = ref.watch(weeklyExpenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo & Thống kê'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card tổng chi tiêu
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng Chi Tiêu Đã Quét',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatVND(totalAmount),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card Biểu đồ Donut Chart (Tỷ trọng danh mục tiêu sài)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tỷ trọng Danh mục Tiêu sài',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: categoryData.isNotEmpty
                    ? AnimatedDonutChart(data: categoryData)
                    : const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text('Chưa có chi tiêu nào được phân loại'),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Biểu đồ cột chi tiêu theo tuần
            WeeklyBarChart(data: weeklyData),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
