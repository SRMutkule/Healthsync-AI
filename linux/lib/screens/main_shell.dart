import 'package:flutter/material.dart';

import 'activity_screen.dart';
import 'ai_health_screen.dart';
import 'dashboard_screen.dart';
import 'device_screen.dart';
import 'nearby_screen.dart';
import 'profile_screen.dart';
import 'vitals_screen.dart';

class _Dest {
  final String title;
  final IconData icon;
  const _Dest(this.title, this.icon);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  static const dests = [
    _Dest('Dashboard', Icons.home_rounded),
    _Dest('Vitals', Icons.favorite_rounded),
    _Dest('Activity', Icons.directions_run_rounded),
    _Dest('AI Health', Icons.smart_toy_rounded),
    _Dest('Nearby', Icons.place_rounded),
    _Dest('Device', Icons.watch_rounded),
    _Dest('Profile', Icons.person_rounded),
  ];

  // Indices shown in the bottom bar; the rest are reachable from the drawer.
  static const barIndices = [0, 1, 2, 3, 6];

  void go(int i) => setState(() => index = i);

  Widget _page() {
    switch (index) {
      case 0:
        return DashboardScreen(onNavigate: go);
      case 1:
        return const VitalsScreen();
      case 2:
        return const ActivityScreen();
      case 3:
        return const AiHealthScreen();
      case 4:
        return const NearbyScreen();
      case 5:
        return const DeviceScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final barPos = barIndices.indexOf(index);
    return Scaffold(
      appBar: AppBar(
        title: Text(index == 0 ? 'HealthSync AI' : dests[index].title),
        actions: [
          IconButton(
            tooltip: 'Device',
            icon: const Icon(Icons.bluetooth),
            onPressed: () => go(5),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                leading: Icon(Icons.monitor_heart, size: 32),
                title: Text('HealthSync AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text('Smart health tracking'),
              ),
              const Divider(),
              for (var i = 0; i < dests.length; i++)
                ListTile(
                  leading: Icon(dests[i].icon),
                  title: Text(dests[i].title),
                  selected: i == index,
                  onTap: () {
                    Navigator.pop(context);
                    go(i);
                  },
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: _page()),
      bottomNavigationBar: barPos < 0
          ? null
          : NavigationBar(
              selectedIndex: barPos,
              onDestinationSelected: (p) => go(barIndices[p]),
              destinations: [
                for (final i in barIndices)
                  NavigationDestination(icon: Icon(dests[i].icon), label: dests[i].title),
              ],
            ),
    );
  }
}
