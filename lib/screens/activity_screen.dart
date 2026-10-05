import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/common.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HealthProvider>();
    final p = context.watch<ProfileProvider>();
    final t = Theme.of(context).textTheme;
    final progress = (h.steps / p.stepGoal).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          color: Colors.teal,
                          backgroundColor: Colors.teal.withValues(alpha: 0.15),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${h.steps}',
                            style: t.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('of ${p.stepGoal} steps', style: t.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  progress >= 1
                      ? 'Goal reached! 🎉'
                      : '${(progress * 100).round()}% of your daily goal',
                  style: t.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Responsive card height
            final double cardHeight = width < 360
                ? 115
                : width < 600
                ? 120
                : width < 900
                ? 130
                : 140;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: cardHeight,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final cards = [
                  SimpleMetricCard(
                    icon: Icons.directions_walk,
                    label: 'Steps',
                    value: '${h.steps}',
                    unit: 'steps',
                    color: Colors.teal,
                  ),

                  SimpleMetricCard(
                    icon: Icons.route,
                    label: 'Distance',
                    value: h.distanceKm.toStringAsFixed(2),
                    unit: 'km',
                    color: Colors.blue,
                  ),

                  SimpleMetricCard(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${h.calories.round()}',
                    unit: 'kcal',
                    color: Colors.deepOrange,
                  ),

                  SimpleMetricCard(
                    icon: Icons.timer,
                    label: 'Active Time',
                    value: '${h.activeMinutes}',
                    unit: 'min',
                    color: Colors.indigo,
                  ),
                ];

                return cards[index];
              },
            );
          },
        ),
        const SectionTitle('Daily step goal'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Slider(
                  value: p.stepGoal.toDouble(),
                  min: 2000,
                  max: 20000,
                  divisions: 36,
                  label: '${p.stepGoal}',
                  onChanged: (v) => p.setStepGoal(v.round()),
                ),
                Text('${p.stepGoal} steps / day'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => h.addSteps(500),
          icon: const Icon(Icons.add),
          label: const Text('Add 500 steps (demo)'),
        ),
        const Text(''),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Steps are simulated. Connect a pedometer plugin or your band\'s step characteristic to use real data.',
            style: t.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
