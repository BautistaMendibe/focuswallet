import 'package:flutter/material.dart';

class AppBudgetTile extends StatefulWidget {
  final String name;
  final double hours;
  final String? icon;
  final Function(double) onChanged;

  const AppBudgetTile({
    super.key,
    required this.name,
    required this.hours,
    this.icon,
    required this.onChanged,
  });

  @override
  State<AppBudgetTile> createState() => _AppBudgetTileState();
}

class _AppBudgetTileState extends State<AppBudgetTile> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.hours;
  }

  @override
  void didUpdateWidget(AppBudgetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hours != widget.hours) {
      _currentValue = widget.hours;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(IconData(int.parse(widget.icon!), fontFamily: 'MaterialIcons')),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentValue.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF009792),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('0h'),
                Expanded(
                  child: Slider(
                    value: _currentValue,
                    min: 0,
                    max: 24,
                    divisions: 48, // Permite incrementos de 0.5 horas
                    activeColor: const Color(0xFF009792),
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      widget.onChanged(value);
                    },
                  ),
                ),
                const Text('24h'),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 