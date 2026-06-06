import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/supervisors_provider.dart';

class SupervisorsScreen extends ConsumerWidget {
  const SupervisorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supervisors = ref.watch(supervisorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(supervisorsProvider.notifier).loadFromApi();
            },
          ),
        ],
      ),
      body: supervisors.isEmpty
          ? const Center(child: Text('No supervisors found'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: supervisors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final supervisor = supervisors[index];
                final specialization =
                    (supervisor['specialization'] as List?)?.join(', ') ?? '';
                final isAvailable = supervisor['isAvailable'] == true;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (supervisor['name']?.toString().isNotEmpty ?? false)
                            ? supervisor['name'].toString()[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(supervisor['name']?.toString() ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(supervisor['designation']?.toString() ?? ''),
                        Text('Department: ${supervisor['department'] ?? ''}'),
                        Text('Specialization: $specialization'),
                        Text('Slots: ${supervisor['availableSlots'] ?? 0}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(isAvailable ? 'Available' : 'Full'),
                      backgroundColor: isAvailable
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
