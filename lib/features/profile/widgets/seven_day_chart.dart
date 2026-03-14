import 'package:flutter/material.dart';

class SevenDayChart extends StatefulWidget {
  const SevenDayChart({super.key});

  @override
  State<SevenDayChart> createState() => _SevenDayChartState();
}

class _SevenDayChartState extends State<SevenDayChart> {
  int? _hoveredBar;

  final List<Map<String, dynamic>> _data = [
    {'day': 'M', 'height': 0.60},
    {'day': 'T', 'height': 0.85},
    {'day': 'W', 'height': 0.45},
    {'day': 'T', 'height': 0.95},
    {'day': 'F', 'height': 0.30},
    {'day': 'S', 'height': 0.70, 'isHighlight': true},
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Velocity',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Trend Analysis',
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
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Text(
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
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_data.length, (index) {
                final item = _data[index];
                final isHighlight = item['isHighlight'] ?? false;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _hoveredBar = index;
                    });
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _hoveredBar = index;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _hoveredBar = null;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: 120.0 * (item['height'] as double),
                          decoration: BoxDecoration(
                            color: isHighlight || _hoveredBar == index
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF4F46E5).withOpacity(0.4),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['day'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isHighlight
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
