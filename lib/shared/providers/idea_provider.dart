import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/idea_model.dart';
import '../services/api_service.dart';

class IdeaNotifier extends StateNotifier<List<IdeaModel>> {
  IdeaNotifier() : super(IdeaModel.dummyIdeas()) {
    loadFromApi(); // App start hone par API se load karo
  }

  // API se saari ideas load karo
  Future<void> loadFromApi() async {
    try {
      final raw = await IdeasApi.getAll();
      state = raw.map(IdeaModel.fromJson).toList();
    } catch (_) {
      // API nahi mili to dummy data rehne do
    }
  }

  // Naya idea API par POST karo aur list mein add karo
  Future<void> addIdea(IdeaModel idea) async {
    try {
      final newId = await IdeasApi.create(idea.toJson());
      final saved = IdeaModel(
        id:                   newId.toString(),
        ownerName:            idea.ownerName,
        ownerId:              idea.ownerId,
        ownerDept:            idea.ownerDept,
        title:                idea.title,
        description:          idea.description,
        technologiesRequired: idea.technologiesRequired,
        skillsRequired:       idea.skillsRequired,
        status:               idea.status,
        createdAt:            DateTime.now(),
      );
      state = [saved, ...state];
    } catch (_) {
      // Offline fallback
      state = [idea, ...state];
    }
  }

  // Idea update karo
  Future<void> updateIdea(IdeaModel idea) async {
    try {
      await IdeasApi.update(int.parse(idea.id), idea.toJson());
    } catch (_) {}
    state = state.map((e) => e.id == idea.id ? idea : e).toList();
  }

  // Idea delete karo
  Future<void> deleteIdea(String id) async {
    try {
      await IdeasApi.delete(int.parse(id));
    } catch (_) {}
    state = state.where((e) => e.id != id).toList();
  }
}

final ideaProvider =
    StateNotifierProvider<IdeaNotifier, List<IdeaModel>>((ref) {
  return IdeaNotifier();
});
