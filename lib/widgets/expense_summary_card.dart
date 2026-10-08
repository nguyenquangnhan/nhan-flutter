import 'package:flutter/material.dart';
import '../models/expense_item.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

/// Component thẻ hiển thị giao dịch chi tiêu tái sử dụng
/// Đáp ứng 100% 4 tiêu chí bài tập Lab trên lớp (Slide 45 Week 7)
class ExpenseSummaryCard extends StatelessWidget {
  final ExpenseItem item;
  final VoidCallback? onTap;

  const ExpenseSummaryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = item.syncStatus == 'pending';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: item.category.color.withValues(alpha: 0.12),
        highlightColor: item.category.color.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 1. Icon bên trong circular container biểu thị danh mục
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.category.icon,
                  color: item.category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // 2. Nội dung chuyển khoản và ngày giờ xếp theo chiều dọc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.transferContent.isNotEmpty
                          ? item.transferContent
                          : item.category.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormatter.formatDateTime(item.transactionTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (item.bankName != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${item.bankName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 3. Số tiền chi tiêu nổi bật theo định dạng VNĐ và cờ trạng thái sync
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatVND(item.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPending ? Icons.cloud_queue : Icons.cloud_done,
                        size: 13,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isPending ? 'Chưa sync' : 'Đã sync',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isPending ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
