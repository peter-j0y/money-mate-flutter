import 'package:flutter/material.dart';

class PortfolioAllocationChart extends StatelessWidget {
  const PortfolioAllocationChart({super.key, required this.items});

  final List<PortfolioAllocationChartItem> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.ratio);
    final normalizedTotal = total <= 0 ? 1 : total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 28,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];

            return Expanded(
              flex: (item.ratio * 100).round().clamp(1, 9999),
              child: Container(
                color: item.color,
                alignment: Alignment.center,
                child:
                    item.ratio / normalizedTotal >= 0.08
                        ? Text(
                          '${item.ratio.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class PortfolioAllocationChartItem {
  const PortfolioAllocationChartItem({required this.ratio, required this.color});

  final double ratio;
  final Color color;
}
