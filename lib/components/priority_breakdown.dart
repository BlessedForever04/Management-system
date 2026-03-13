import 'dart:math';
import 'package:flutter/material.dart';
import 'package:managementt/components/app_colors.dart';

class PriorityBreakdown extends StatelessWidget {
  final int highCount;
  final int mediumCount;
  final int lowCount;

  const PriorityBreakdown({
    super.key,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: 120,
                  child: _SimpleDonutChart(
                    highPriority: highCount.toDouble(),
                    mediumPriority: mediumCount.toDouble(),
                    lowPriority: lowCount.toDouble(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PriorityItem(
                      label: 'High',
                      count: highCount,
                      color: AppColors.priorityHigh,
                    ),
                    const SizedBox(height: 12),
                    _PriorityItem(
                      label: 'Medium',
                      count: mediumCount,
                      color: AppColors.priorityMedium,
                    ),
                    const SizedBox(height: 12),
                    _PriorityItem(
                      label: 'Low',
                      count: lowCount,
                      color: AppColors.priorityLow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimpleDonutChart extends StatelessWidget {
  final double highPriority;
  final double mediumPriority;
  final double lowPriority;

  const _SimpleDonutChart({
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
  });

  @override
  Widget build(BuildContext context) {
    final total = highPriority + mediumPriority + lowPriority;

    if (total == 0) {
      return const Center(child: Text("No Data"));
    }

    return CustomPaint(
      size: const Size(120, 120),
      painter: _DonutPainter(highPriority, mediumPriority, lowPriority, total),
      child: const Center(child: SizedBox(width: 40, height: 40)),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double high;
  final double medium;
  final double low;
  final double total;

  _DonutPainter(this.high, this.medium, this.low, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: 50,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    final highAngle = (high / total) * 2 * pi;
    paint.color = AppColors.priorityHigh;
    canvas.drawArc(rect, startAngle, highAngle, false, paint);
    startAngle += highAngle;

    final mediumAngle = (medium / total) * 2 * pi;
    paint.color = AppColors.priorityMedium;
    canvas.drawArc(rect, startAngle, mediumAngle, false, paint);
    startAngle += mediumAngle;

    final lowAngle = (low / total) * 2 * pi;
    paint.color = AppColors.priorityLow;
    canvas.drawArc(rect, startAngle, lowAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _PriorityItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _PriorityItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
