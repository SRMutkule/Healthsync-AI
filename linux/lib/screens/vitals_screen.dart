import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../utils/status.dart';
import '../widgets/common.dart';

class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HealthProvider>();
    return DefaultTabController(
      length: 4,
      child: Column(children: [
        const TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(icon: Icon(Icons.favorite), text: 'Heart Rate'),
            Tab(icon: Icon(Icons.air), text: 'SpO₂'),
            Tab(icon: Icon(Icons.speed), text: 'Blood Pressure'),
            Tab(icon: Icon(Icons.thermostat), text: 'Temperature'),
          ],
        ),
        Expanded(
          child: TabBarView(children: [
            _VitalPage(
              value: '${h.heartRate.round()}',
              unit: 'bpm',
              status: hrStatus(h.heartRate),
              range: 'Normal resting range: 60–100 bpm',
              series: [h.hrHistory],
              colors: const [Colors.redAccent],
              minY: 40,
              maxY: 140,
            ),
            _VitalPage(
              value: '${h.spo2.round()}',
              unit: '%',
              status: spo2Status(h.spo2),
              range: 'Normal range: 95–100%',
              series: [h.spo2History],
              colors: const [Colors.blue],
              minY: 85,
              maxY: 100,
            ),
            _VitalPage(
              value: '${h.systolic.round()}/${h.diastolic.round()}',
              unit: 'mmHg',
              status: bpStatus(h.systolic, h.diastolic),
              range: 'Ideal: below 120/80 mmHg (systolic, diastolic)',
              series: [h.sysHistory, h.diaHistory],
              colors: const [Colors.purple, Colors.pinkAccent],
              minY: 50,
              maxY: 160,
            ),
            _VitalPage(
              value: h.temperature.toStringAsFixed(1),
              unit: '°C',
              status: tempStatus(h.temperature),
              range: 'Normal range: 36.0–37.4 °C',
              series: [h.tempHistory],
              colors: const [Colors.orange],
              minY: 35,
              maxY: 39,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _VitalPage extends StatelessWidget {
  final String value, unit, range;
  final Status status;
  final List<List<double>> series;
  final List<Color> colors;
  final double minY, maxY;

  const _VitalPage({
    required this.value,
    required this.unit,
    required this.status,
    required this.range,
    required this.series,
    required this.colors,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: t.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Text(unit, style: t.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            StatusChip(status),
            const SizedBox(height: 8),
            Text(range, style: t.bodySmall),
          ]),
        ),
      ),
      const SectionTitle('Recent trend'),
      Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
          child: SizedBox(
            height: 220,
            child: series.first.length < 2
                ? const Center(child: Text('Collecting data…'))
                : LineChart(LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: const FlGridData(drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                    ),
                    lineBarsData: [
                      for (var i = 0; i < series.length; i++)
                        LineChartBarData(
                          spots: [
                            for (var j = 0; j < series[i].length; j++) FlSpot(j.toDouble(), series[i][j]),
                          ],
                          isCurved: true,
                          color: colors[i],
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: i == 0, color: colors[i].withOpacity(0.12)),
                        ),
                    ],
                  )),
          ),
        ),
      ),
      const Disclaimer(),
    ]);
  }
}
