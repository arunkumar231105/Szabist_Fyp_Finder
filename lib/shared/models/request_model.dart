class RequestModel {
  const RequestModel({
    required this.id,
    required this.senderName,
    required this.senderDept,
    required this.receiverName,
    required this.message,
    required this.status,
    this.withdrawReason,
  });

  final String id;
  final String senderName;
  final String senderDept;
  final String receiverName;
  final String message;
  final String status;
  final String? withdrawReason;

  RequestModel copyWith({
    String? id,
    String? senderName,
    String? senderDept,
    String? receiverName,
    String? message,
    String? status,
    String? withdrawReason,
    bool clearWithdrawReason = false,
  }) {
    return RequestModel(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderDept: senderDept ?? this.senderDept,
      receiverName: receiverName ?? this.receiverName,
      message: message ?? this.message,
      status: status ?? this.status,
      withdrawReason: clearWithdrawReason
          ? null
          : (withdrawReason ?? this.withdrawReason),
    );
  }

  static List<RequestModel> dummyIncoming() {
    return const <RequestModel>[
      RequestModel(
        id: 'req_in_001',
        senderName: 'Ayesha Khan',
        senderDept: 'CS',
        receiverName: 'Arun Kumar',
        message: 'I love mobile dev too. Want to team up for a cross-platform FYP?',
        status: 'pending',
      ),
      RequestModel(
        id: 'req_in_002',
        senderName: 'Maham Raza',
        senderDept: 'AI',
        receiverName: 'Arun Kumar',
        message: 'Your AI and app background feels like a strong match for my vision idea.',
        status: 'pending',
      ),
      RequestModel(
        id: 'req_in_003',
        senderName: 'Sara Noor',
        senderDept: 'CS',
        receiverName: 'Arun Kumar',
        message: 'Interested in building something security-focused with mobile and ML?',
        status: 'pending',
      ),
    ];
  }

  static List<RequestModel> dummyOutgoing() {
    return const <RequestModel>[
      RequestModel(
        id: 'req_out_001',
        senderName: 'Arun Kumar',
        senderDept: 'SE',
        receiverName: 'Bilal Ahmed',
        message: 'Your backend skills would pair nicely with my Flutter experience.',
        status: 'pending',
      ),
      RequestModel(
        id: 'req_out_002',
        senderName: 'Arun Kumar',
        senderDept: 'SE',
        receiverName: 'Hamza Ali',
        message: 'Thinking of an IoT + app combo project if you are interested.',
        status: 'accepted',
      ),
    ];
  }
}
