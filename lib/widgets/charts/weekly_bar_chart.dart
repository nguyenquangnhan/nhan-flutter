import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/expense_notifier.dart';
import '../../core/utils/currency_formatter.dart';

/// CustomPainter tự vẽ biểu đồ cột chi tiêu theo tuần
class WeeklyBarPainter extends CustomPainter {
  final List<DayExpenseData> data;
  final double progress;
  final Color barColor;
  final Color gridColor;
  final Color textColor;

  WeeklyBarPainter({
    required this.data,
    required this.progress,
    required this.barColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxAmount = data.map((d) => d.amount).fold(0.0, max);
    final effectiveMax = maxAmount > 0 ? maxAmount * 1.15 : 100000.0;

    final bottomPadding = 28.0;
    final topPadding = 16.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final barWidth = size.width / (data.length * 2);

    final linePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Vẽ đường kẻ trục đáy
    canvas.drawLine(
      Offset(0, size.height - bottomPadding),
      Offset(size.width, size.height - bottomPadding),
      linePaint,
    );

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = (i * 2 + 1) * barWidth;
      final normalizedHeight = (item.amount / effectiveMax) * chartHeight * progress;
      final y = size.height - bottomPadding - normalizedHeight;

      // Vẽ thanh cột bo tròn đầu
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - barWidth / 2, y, barWidth, normalizedHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, barPaint);

      // Vẽ nhãn ngày ở đáy (CN, T2...)
      textPainter.text = TextSpan(
        text: item.dayLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPadding + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data ||
        oldDelegate.barColor != barColor;
  }
}

/// Widget bọc AnimationController cho biểu đồ cột
class WeeklyBarChart extends StatefulWidget {
  final List<DayExpenseData> data;

  const WeeklyBarChart({
    super.key,
    required this.data,
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWeekly = widget.data.fold(0.0, (sum, d) => sum + d.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiêu 7 ngày qua',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatVND(totalWeekly),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => CustomPaint(
                  painter: WeeklyBarPainter(
                    data: widget.data,
                    progress: _animation.value,
                    barColor: theme.colorScheme.primary,
                    gridColor: theme.colorScheme.outlineVariant,
                    textColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
