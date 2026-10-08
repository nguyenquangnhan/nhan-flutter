import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/expense_notifier.dart';

/// CustomPainter vẽ biểu đồ Donut Chart (Tuần 8 Slide 33)
class DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;
  final double progress; // 0.0 -> 1.0

  DonutChartPainter({
    required this.percentages,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (percentages.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 16;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final sweep = (2 * pi * percentages[i]) * progress;
      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.percentages != percentages ||
        oldDelegate.colors != colors;
  }
}

/// Widget bọc AnimationController kết nối với DonutChartPainter (Tuần 8 Slide 34)
class AnimatedDonutChart extends StatefulWidget {
  final List<CategoryChartData> data;

  const AnimatedDonutChart({
    super.key,
    required this.data,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDonutChart oldWidget) {
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
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Chưa có dữ liệu chi tiêu')),
      );
    }

    final percentages = widget.data.map((d) => d.percentage).toList();
    final colors = widget.data.map((d) => d.category.color).toList();

    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => CustomPaint(
              size: const Size(200, 200),
              painter: DonutChartPainter(
                percentages: percentages,
                colors: colors,
                progress: _animation.value,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Chú giải danh mục (Legend)
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.category.displayName} (${(item.percentage * 100).toStringAsFixed(0)}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
