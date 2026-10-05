import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/status.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HealthProvider>();
    final p = context.watch<ProfileProvider>();
    final score = h.healthScore(p.stepGoal);
    final scoreColor = score >= 80
        ? levelColor(Level.good)
        : score >= 60
        ? levelColor(Level.warn)
        : levelColor(Level.bad);
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hello, ${p.name} 👋',
          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 9,
                          color: scoreColor,
                          backgroundColor: scoreColor.withValues(alpha: 0.15),
                        ),
                      ),
                      Text(
                        '$score',
                        style: t.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Health Score', style: t.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        score >= 80
                            ? 'You are doing great today.'
                            : score >= 60
                            ? 'Some readings need attention.'
                            : 'Several readings are off. Check the AI tab.',
                        style: t.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      ActionChip(
                        avatar: Icon(
                          h.connected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          size: 18,
                        ),
                        label: Text(h.connected ? h.deviceName : 'No device'),
                        onPressed: () => onNavigate(5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('Today'),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Responsive columns
            final int columns = width < 600
                ? 2
                : width < 900
                ? 3
                : 4;

            // Responsive card height
            final double cardHeight = width < 360
                ? 135
                : width < 600
                ? 140
                : width < 900
                ? 145
                : 150;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              mainAxisSpacing: 10,
              crossAxisSpacing: 10,

              // Prevents RenderFlex overflow
              mainAxisExtent: cardHeight,

              children: [
                MetricCard(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  value: '${h.heartRate.round()}',
                  unit: 'bpm',
                  color: Colors.redAccent,
                  status: hrStatus(h.heartRate),
                  onTap: () => onNavigate(1),
                ),

                MetricCard(
                  icon: Icons.air,
                  label: 'SpO₂',
                  value: '${h.spo2.round()}',
                  unit: '%',
                  color: Colors.blue,
                  status: spo2Status(h.spo2),
                  onTap: () => onNavigate(1),
                ),

                MetricCard(
                  icon: Icons.speed,
                  label: 'Blood Pressure',
                  value: '${h.systolic.round()}/${h.diastolic.round()}',
                  unit: 'mmHg',
                  color: Colors.purple,
                  status: bpStatus(h.systolic, h.diastolic),
                  onTap: () => onNavigate(1),
                ),

                MetricCard(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: h.temperature.toStringAsFixed(1),
                  unit: '°C',
                  color: Colors.orange,
                  status: tempStatus(h.temperature),
                  onTap: () => onNavigate(1),
                ),

                MetricCard(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: '${h.steps}',
                  unit: '/ ${p.stepGoal}',
                  color: Colors.teal,
                  onTap: () => onNavigate(2),
                ),

                MetricCard(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '${h.calories.round()}',
                  unit: 'kcal',
                  color: Colors.deepOrange,
                  onTap: () => onNavigate(2),
                ),

                MetricCard(
                  icon: Icons.timer,
                  label: 'Activity',
                  value: '${h.activeMinutes}',
                  unit: 'min active',
                  color: Colors.indigo,
                  onTap: () => onNavigate(2),
                ),

                MetricCard(
                  icon: Icons.smart_toy,
                  label: 'AI Insights',
                  value: 'View',
                  unit: '',
                  color: Colors.green,
                  onTap: () => onNavigate(3),
                ),
              ],
            );
          },
        ),
        const Disclaimer(),
      ],
    );
  }
}
