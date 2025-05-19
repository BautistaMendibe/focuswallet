import 'package:flutter/material.dart';

class TodayUseCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final double totalAmount;
  final double totalTime; // en horas, ej: 1.5
  final List<AppUsage> apps;

  const TodayUseCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.totalAmount,
    required this.totalTime,
    required this.apps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de categoría
          Row(
            children: [
              CircleAvatar(
               backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('\$${totalAmount.toStringAsFixed(1)} (${totalTime}h)',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de apps
          Column(
            children: apps.map((app) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(app.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('\$${app.amount.toStringAsFixed(1)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: app.progress,
                      backgroundColor: Colors.grey[300],
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text("Left \$${app.left.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class AppUsage {
  final String name;
  final double amount;
  final double progress; // entre 0 y 1
  final double left;

  AppUsage({
    required this.name,
    required this.amount,
    required this.progress,
    required this.left,
  });
}
