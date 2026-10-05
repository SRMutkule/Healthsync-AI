import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/profile_provider.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    ProfileProvider p,
    String key,
    String label, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) async {
    final ctrl = TextEditingController(text: p.data[key]);
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: type,
          maxLines: maxLines,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    if (saved != null) await p.setField(key, saved);
  }

  Widget _row(BuildContext c, ProfileProvider p, String key, String label, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1, String suffix = ''}) {
    final v = p.data[key] ?? '';
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(v.isEmpty ? 'Tap to add' : '$v$suffix'),
      trailing: const Icon(Icons.edit, size: 18),
      onTap: () => _edit(c, p, key, label, type: type, maxLines: maxLines),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final phone = p.data['ecPhone'] ?? '';

    return ListView(padding: const EdgeInsets.all(16), children: [
      const SectionTitle('Personal Information'),
      Card(
        child: Column(children: [
          _row(context, p, 'name', 'Name', Icons.person),
          _row(context, p, 'age', 'Age', Icons.cake, type: TextInputType.number),
          _row(context, p, 'gender', 'Gender', Icons.wc),
          _row(context, p, 'height', 'Height', Icons.height, type: TextInputType.number, suffix: ' cm'),
          _row(context, p, 'weight', 'Weight', Icons.monitor_weight, type: TextInputType.number, suffix: ' kg'),
        ]),
      ),
      const SectionTitle('Medical History'),
      Card(
        child: Column(children: [
          _row(context, p, 'blood', 'Blood group', Icons.bloodtype),
          _row(context, p, 'conditions', 'Conditions', Icons.medical_information, maxLines: 3),
          _row(context, p, 'allergies', 'Allergies', Icons.warning_amber, maxLines: 3),
          _row(context, p, 'medications', 'Medications', Icons.medication, maxLines: 3),
        ]),
      ),
      const SectionTitle('Emergency Contact'),
      Card(
        child: Column(children: [
          _row(context, p, 'ecName', 'Contact name', Icons.contact_emergency),
          _row(context, p, 'ecRelation', 'Relationship', Icons.family_restroom),
          _row(context, p, 'ecPhone', 'Phone number', Icons.phone, type: TextInputType.phone),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: phone.isEmpty ? null : () => launchUrl(Uri.parse('tel:$phone')),
                icon: const Icon(Icons.call),
                label: const Text('Call emergency contact'),
              ),
            ),
          ),
        ]),
      ),
      const SectionTitle('Settings'),
      Card(
        child: Column(children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            value: p.darkMode,
            onChanged: p.setDark,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Health alerts'),
            value: p.notifications,
            onChanged: p.setNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear all my data'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear all data?'),
                  content: const Text('This removes your profile and settings from this device.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                  ],
                ),
              );
              if (ok == true) await p.clearAll();
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('HealthSync AI'),
            subtitle: Text('Version 1.0.0 • Data is stored only on this device'),
          ),
        ]),
      ),
      const Disclaimer(),
    ]);
  }
}
