import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/request_model.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';

class RequestsState {
  const RequestsState({
    required this.incoming,
    required this.outgoing,
    this.acceptedPartnerName,
  });

  final List<RequestModel> incoming;
  final List<RequestModel> outgoing;
  final String? acceptedPartnerName;

  bool get hasPendingOutgoing =>
      outgoing.any((request) => request.status == 'pending');
  bool get hasAcceptedPartner => acceptedPartnerName != null;
  bool get canCreateNewRequest => !hasPendingOutgoing && !hasAcceptedPartner;

  RequestsState copyWith({
    List<RequestModel>? incoming,
    List<RequestModel>? outgoing,
    String? acceptedPartnerName,
    bool clearAcceptedPartner = false,
  }) {
    return RequestsState(
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
      acceptedPartnerName: clearAcceptedPartner
          ? null
          : (acceptedPartnerName ?? this.acceptedPartnerName),
    );
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  RequestsNotifier() : super(const RequestsState(incoming: [], outgoing: [])) {
    loadFromApi();
  }

  Future<void> loadFromApi() async {
    try {
      final incomingRaw = await RequestsApi.getIncoming();
      final outgoingRaw = await RequestsApi.getOutgoing();

      final incoming = incomingRaw.map(RequestModel.fromApiJson).toList();
      final outgoing = outgoingRaw.map(RequestModel.fromApiJson).toList();
      final acceptedPartner = _acceptedPartnerName(incoming, outgoing);

      state = state.copyWith(
        incoming: incoming,
        outgoing: outgoing,
        acceptedPartnerName: acceptedPartner,
        clearAcceptedPartner: acceptedPartner == null,
      );
    } catch (_) {}
  }

  Future<bool> acceptIncoming(String requestId) async {
    try {
      await RequestsApi.accept(int.parse(requestId));
      await loadFromApi();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> rejectIncoming(String requestId) async {
    try {
      await RequestsApi.reject(int.parse(requestId));
      await loadFromApi();
    } catch (_) {}
  }

  Future<void> cancelOutgoing(String requestId) async {
    try {
      await RequestsApi.delete(int.parse(requestId));
      await loadFromApi();
    } catch (_) {}
  }

  Future<bool> addOutgoingRequest({
    required StudentModel currentStudent,
    required StudentModel targetStudent,
    required String message,
  }) async {
    if (!state.canCreateNewRequest) return false;

    final msg = message.trim().isEmpty
        ? 'Hi! I think we would make a great team.'
        : message.trim();

    try {
      await RequestsApi.create({
        'receiverId': int.tryParse(targetStudent.id) ?? 0,
        'message': msg,
      });
      await loadFromApi();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> withdrawAcceptedPartner(String requestId) async {
    await cancelOutgoing(requestId);
  }

  static String? _acceptedPartnerName(
    List<RequestModel> incoming,
    List<RequestModel> outgoing,
  ) {
    for (final request in incoming) {
      if (request.status == 'accepted') return request.senderName;
    }

    for (final request in outgoing) {
      if (request.status == 'accepted') return request.receiverName;
    }

    return null;
  }
}

final requestsProvider = StateNotifierProvider<RequestsNotifier, RequestsState>(
  (ref) {
    return RequestsNotifier();
  },
);
