import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/common.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  Future<void> _open(BuildContext context, String query) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open maps.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Hospitals', 'Emergency & multispeciality care', Icons.local_hospital, Colors.red, 'hospitals near me'),
      ('Clinics', 'General physicians & specialists', Icons.medical_services, Colors.teal, 'clinics near me'),
      ('Pharmacies', 'Medicines & health supplies', Icons.local_pharmacy, Colors.green, 'pharmacies near me'),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: const Icon(Icons.emergency),
          title: const Text('Emergency?'),
          subtitle: const Text('Call 112 immediately.'),
          trailing: FilledButton(
            onPressed: () => launchUrl(Uri.parse('tel:112')),
            child: const Text('Call 112'),
          ),
        ),
      ),
      const SectionTitle('Find care near you'),
      for (final it in items)
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: it.$4.withValues(alpha: 0.15),
              child: Icon(it.$3, color: it.$4),
            ),
            title: Text(it.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(it.$2),
            trailing: const Icon(Icons.map),
            onTap: () => _open(context, it.$5),
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text('Opens your maps app using your current location.',
            style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      ),
    ]);
  }
}
