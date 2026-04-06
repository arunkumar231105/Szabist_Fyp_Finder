import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/idea_model.dart';

class IdeaNotifier extends StateNotifier<List<IdeaModel>> {
  IdeaNotifier() : super(IdeaModel.dummyIdeas());

  void addIdea(IdeaModel idea) {
    state = <IdeaModel>[idea, ...state];
  }
}

final ideaProvider =
    StateNotifierProvider<IdeaNotifier, List<IdeaModel>>((ref) {
  return IdeaNotifier();
});
