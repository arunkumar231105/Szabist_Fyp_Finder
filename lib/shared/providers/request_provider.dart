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
      outgoing.any((r) => r.status == 'pending');
  bool get hasAcceptedPartner => acceptedPartnerName != null;
  bool get canCreateNewRequest => !hasPendingOutgoing && !hasAcceptedPartner;

  RequestsState copyWith({
    List<RequestModel>? incoming,
    List<RequestModel>? outgoing,
    String? acceptedPartnerName,
    bool clearAcceptedPartner = false,
  }) =>
      RequestsState(
        incoming: incoming ?? this.incoming,
        outgoing: outgoing ?? this.outgoing,
        acceptedPartnerName: clearAcceptedPartner
            ? null
            : (acceptedPartnerName ?? this.acceptedPartnerName),
      );
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  RequestsNotifier()
      : super(const RequestsState(incoming: [], outgoing: [])) {
    loadFromApi();
  }

  Future<void> loadFromApi() async {
    try {
      final all = await RequestsApi.getAll();

      final List<RequestModel> incoming = all
          .where((r) => r['receiver_name'] == 'Arun Kumar')
          .map((r) => RequestModel.fromApiJson(r))
          .toList();

      final List<RequestModel> outgoing = all
          .where((r) => r['sender_name'] == 'Arun Kumar')
          .map((r) => RequestModel.fromApiJson(r))
          .toList();

      state = state.copyWith(incoming: incoming, outgoing: outgoing);
    } catch (_) {
      // keep empty state on API error
    }
  }

  Future<bool> acceptIncoming(String requestId) async {
    final req =
        state.incoming.firstWhere((r) => r.id == requestId);
    try {
      await RequestsApi.update(int.parse(requestId), {
        'senderName':   req.senderName,
        'senderDept':   req.senderDept,
        'receiverName': req.receiverName,
        'message':      req.message,
        'status':       'accepted',
      });
    } catch (_) {}

    state = state.copyWith(
      acceptedPartnerName: req.senderName,
      incoming: state.incoming.map((r) {
        if (r.id == requestId) return r.copyWith(status: 'accepted');
        if (r.status == 'pending') return r.copyWith(status: 'rejected');
        return r;
      }).toList(),
    );
    return true;
  }

  void rejectIncoming(String requestId) {
    state = state.copyWith(
      incoming: state.incoming
          .map((r) =>
              r.id == requestId ? r.copyWith(status: 'rejected') : r)
          .toList(),
    );
  }

  void cancelOutgoing(String requestId) {
    state = state.copyWith(
      outgoing: state.outgoing
          .map((r) =>
              r.id == requestId ? r.copyWith(status: 'rejected') : r)
          .toList(),
    );
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
      final newId = await RequestsApi.create({
        'senderName':   currentStudent.name,
        'senderDept':   currentStudent.department,
        'receiverName': targetStudent.name,
        'message':      msg,
      });
      state = state.copyWith(
        outgoing: [
          RequestModel(
            id:           newId.toString(),
            senderName:   currentStudent.name,
            senderDept:   currentStudent.department,
            receiverName: targetStudent.name,
            message:      msg,
            status:       'pending',
          ),
          ...state.outgoing,
        ],
      );
    } catch (_) {
      return false;
    }
    return true;
  }

  void withdrawAcceptedPartner(String requestId) {
    state = state.copyWith(
      clearAcceptedPartner: true,
      incoming: state.incoming.map((r) {
        if (r.id == requestId && r.status == 'accepted') {
          return r.copyWith(status: 'withdrawn', clearWithdrawReason: true);
        }
        if (r.status == 'rejected') {
          return r.copyWith(status: 'pending', clearWithdrawReason: true);
        }
        return r;
      }).toList(),
      outgoing: state.outgoing.map((r) {
        if (r.status == 'rejected') {
          return r.copyWith(status: 'pending', clearWithdrawReason: true);
        }
        return r;
      }).toList(),
    );
  }
}

final requestsProvider =
    StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  return RequestsNotifier();
});
