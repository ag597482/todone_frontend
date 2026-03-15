import 'package:flutter/material.dart';

class SevenDayChart extends StatefulWidget {
  const SevenDayChart({super.key});

  @override
  State<SevenDayChart> createState() => _SevenDayChartState();
}

class _SevenDayChartState extends State<SevenDayChart> {
  int? _hoveredIndex;

  final List<Map<String, dynamic>> _data = [
    {'day': 'M', 'height': 0.60},
    {'day': 'T', 'height': 0.85},
    {'day': 'W', 'height': 0.45},
    {'day': 'T', 'height': 0.95},
    {'day': 'F', 'height': 0.30},
    {'day': 'S', 'height': 0.70},
    {'day': 'S', 'height': 0.20},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productivity Analysis',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This week',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 12,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Oct 14 - 20',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 136,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final chartHeight = 96.0;
                final topPadding = 8.0;
                final labelHeight = 24.0;
                final h = topPadding + chartHeight + labelHeight;
                final stepX = _data.length > 1 ? w / (_data.length - 1) : w;
                final points = <Offset>[];
                for (var i = 0; i < _data.length; i++) {
                  final y = topPadding + chartHeight * (1.0 - (_data[i]['height'] as double));
                  final x = i * stepX;
                  points.add(Offset(x, y));
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(w, h),
                      painter: _LineChartPainter(
                        points: points,
                        lineColor: const Color(0xFF4F46E5),
                        highlightIndex: _hoveredIndex,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: labelHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_data.length, (index) {
                          final item = _data[index];
                          final isHighlight = _hoveredIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _hoveredIndex = _hoveredIndex == index ? null : index;
                              });
                            },
                            child: Text(
                              item['day'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isHighlight
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.lineColor,
    this.highlightIndex,
  });

  final List<Offset> points;
  final Color lineColor;
  final int? highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final dotRadius = 4.0;
    for (var i = 0; i < points.length; i++) {
      final isHighlight = highlightIndex == i;
      final paint = Paint()
        ..color = isHighlight ? lineColor : lineColor.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], dotRadius, paint);
      final strokePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(points[i], dotRadius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.highlightIndex != highlightIndex ||
        oldDelegate.points.length != points.length;
  }
}
