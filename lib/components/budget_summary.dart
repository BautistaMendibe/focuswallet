import 'package:flutter/material.dart';

class BudgetSummary extends StatelessWidget {
  final double spentAmount;
  final double spentHours;
  final double budgetAmount;
  final double budgetHours;

  final List<BudgetSegment> segments;

  const BudgetSummary({
    super.key,
    required this.spentAmount,
    required this.spentHours,
    required this.budgetAmount,
    required this.budgetHours,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Labels
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text("Spent"),
                    Text("\$$spentAmount (${spentHours.toStringAsFixed(0)}h)",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text("Daily budget"),
                    Text("\$$budgetAmount (${budgetHours.toStringAsFixed(0)}h)",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar compuesta
          SizedBox(
            height: 10,
            child: LayoutBuilder(builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Row(
                children: segments.map((segment) {
                  final widthFraction = segment.fraction.clamp(0.0, 1.0);
                  return Container(
                    width: totalWidth * widthFraction,
                    height: 10,
                    color: segment.color,
                  );
                }).toList(),
              );
            }),
          )
        ],
      ),
    );
  }
}

class BudgetSegment {
  final double fraction; // entre 0 y 1, suma total debe ser <= 1
  final Color color;

  BudgetSegment({required this.fraction, required this.color});
}
