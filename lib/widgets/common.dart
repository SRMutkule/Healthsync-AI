import 'package:flutter/material.dart';

import '../utils/status.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final Status? status;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(label, style: t.labelLarge, overflow: TextOverflow.ellipsis)),
              ]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(value, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(unit, style: t.bodySmall),
                ],
              ),
              status == null ? const SizedBox(height: 20) : StatusChip(status!),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final Status status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: status.color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'HealthSync AI is for general wellness information only and is not a medical device or a substitute for professional advice. In an emergency call 112.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      );
}
