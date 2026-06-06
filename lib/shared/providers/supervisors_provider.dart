import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';

class SupervisorsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  SupervisorsNotifier() : super([]) {
    loadFromApi();
  }

  Future<void> loadFromApi({bool? available}) async {
    try {
      final data = await SupervisorsApi.getAll(available: available);
      state = data;
    } catch (_) {
      state = [];
    }
  }
}

final supervisorsProvider =
    StateNotifierProvider<SupervisorsNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return SupervisorsNotifier();
    });
