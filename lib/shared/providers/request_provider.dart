import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/request_model.dart';
import '../models/student_model.dart';

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
      outgoing.any((RequestModel request) => request.status == 'pending');

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
      acceptedPartnerName:
          clearAcceptedPartner ? null : (acceptedPartnerName ?? this.acceptedPartnerName),
    );
  }

  static RequestsState dummy() {
    return RequestsState(
      incoming: RequestModel.dummyIncoming(),
      outgoing: RequestModel.dummyOutgoing(),
      acceptedPartnerName: null,
    );
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  RequestsNotifier() : super(RequestsState.dummy());

  bool acceptIncoming(String requestId) {
    final RequestModel request = state.incoming.firstWhere(
      (RequestModel item) => item.id == requestId,
    );

    if (state.acceptedPartnerName != null &&
        state.acceptedPartnerName != request.senderName) {
      return false;
    }

    state = state.copyWith(
      acceptedPartnerName: request.senderName,
      incoming: state.incoming
          .map((RequestModel item) {
            if (item.id == requestId) {
              return item.copyWith(status: 'accepted');
            }
            if (item.status == 'pending') {
              return item.copyWith(status: 'rejected');
            }
            return item;
          })
          .toList(),
      outgoing: state.outgoing
          .map(
            (RequestModel item) => item.status == 'pending'
                ? item.copyWith(status: 'rejected')
                : item,
          )
          .toList(),
    );
    return true;
  }

  void rejectIncoming(String requestId) {
    state = state.copyWith(
      incoming: state.incoming
          .map(
            (RequestModel item) =>
                item.id == requestId ? item.copyWith(status: 'rejected') : item,
          )
          .toList(),
    );
  }

  void cancelOutgoing(String requestId) {
    state = state.copyWith(
      outgoing: state.outgoing
          .map(
            (RequestModel item) =>
                item.id == requestId ? item.copyWith(status: 'rejected') : item,
          )
          .toList(),
    );
  }

  bool addOutgoingRequest({
    required StudentModel currentStudent,
    required StudentModel targetStudent,
    required String message,
  }) {
    if (!state.canCreateNewRequest) {
      return false;
    }

    state = state.copyWith(
      outgoing: <RequestModel>[
        RequestModel(
          id: 'req_out_${DateTime.now().millisecondsSinceEpoch}',
          senderName: currentStudent.name,
          senderDept: currentStudent.department,
          receiverName: targetStudent.name,
          message: message.trim().isEmpty
              ? 'Hi! I think we would make a great team.'
              : message.trim(),
          status: 'pending',
        ),
        ...state.outgoing,
      ],
    );
    return true;
  }

  void withdrawAcceptedPartner(String requestId) {
    state = state.copyWith(
      clearAcceptedPartner: true,
      incoming: state.incoming
          .map((RequestModel item) {
            if (item.id == requestId && item.status == 'accepted') {
              return item.copyWith(
                status: 'withdrawn',
                clearWithdrawReason: true,
              );
            }
            if (item.status == 'rejected') {
              return item.copyWith(
                status: 'pending',
                clearWithdrawReason: true,
              );
            }
            return item;
          })
          .toList(),
      outgoing: state.outgoing
          .map((RequestModel item) {
            if (item.status == 'rejected') {
              return item.copyWith(
                status: 'pending',
                clearWithdrawReason: true,
              );
            }
            return item;
          })
          .toList(),
    );
  }
}

final requestsProvider =
    StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  return RequestsNotifier();
});
