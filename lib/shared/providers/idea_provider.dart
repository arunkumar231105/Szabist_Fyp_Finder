import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/idea_model.dart';
import '../services/api_service.dart';

class IdeaNotifier extends StateNotifier<List<IdeaModel>> {
  IdeaNotifier() : super([]) {
    loadFromApi();
  }

  Future<void> loadFromApi() async {
    try {
      final raw = await IdeasApi.getAll();
      state = raw.map(IdeaModel.fromJson).toList();
    } catch (_) {}
  }

  Future<void> addIdea(IdeaModel idea) async {
    try {
      await IdeasApi.create(idea.toJson());
      await loadFromApi();
    } catch (_) {}
  }

  Future<void> updateIdea(IdeaModel idea) async {
    try {
      await IdeasApi.update(int.parse(idea.id), idea.toJson());
      state = state.map((item) => item.id == idea.id ? idea : item).toList();
    } catch (_) {}
  }

  Future<void> deleteIdea(String id) async {
    try {
      await IdeasApi.delete(int.parse(id));
      state = state.where((idea) => idea.id != id).toList();
    } catch (_) {}
  }
}

final ideaProvider = StateNotifierProvider<IdeaNotifier, List<IdeaModel>>((
  ref,
) {
  return IdeaNotifier();
});
