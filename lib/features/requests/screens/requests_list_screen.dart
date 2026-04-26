import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../core/utils/string_utils.dart';
import '../../../shared/models/request_model.dart';
import '../../../shared/providers/request_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';

class RequestsListScreen extends ConsumerStatefulWidget {
  const RequestsListScreen({
    this.showAppBar = true,
    super.key,
  });

  final bool showAppBar;

  @override
  ConsumerState<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends ConsumerState<RequestsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RequestsState requestsState = ref.watch(requestsProvider);

    final Widget tabBar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.showAppBar
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: widget.showAppBar ? Colors.white : AppColors.lightPurple,
            borderRadius: BorderRadius.circular(999),
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor:
              widget.showAppBar ? Colors.white : const Color(0xFF64748B),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: <Widget>[
            Tab(text: 'Incoming (${requestsState.incoming.length})'),
            Tab(text: 'Sent (${requestsState.outgoing.length})'),
          ],
        ),
      ),
    );

    final Widget tabViews = TabBarView(
      controller: _tabController,
      children: <Widget>[
        requestsState.incoming.isEmpty
            ? const _EmptyRequests(text: 'No incoming requests')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requestsState.incoming.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final RequestModel request = requestsState.incoming[index];
                  return _IncomingRequestCard(
                    request: request,
                    onAccept: () => _acceptRequest(context, request),
                    onReject: () {
                      ref.read(requestsProvider.notifier).rejectIncoming(request.id);
                      _showSnackBar(context, 'Request rejected');
                    },
                    onWithdraw: request.status == 'accepted'
                        ? () => _withdrawAcceptedRequest(context, request)
                        : null,
                  );
                },
              ),
        requestsState.outgoing.isEmpty
            ? const _EmptyRequests(text: 'No sent requests')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requestsState.outgoing.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final RequestModel request = requestsState.outgoing[index];
                  return _SentRequestCard(
                    request: request,
                    onCancel: request.status == 'pending'
                        ? () {
                            ref.read(requestsProvider.notifier).cancelOutgoing(request.id);
                            _showSnackBar(context, 'Request withdrawn.');
                          }
                        : null,
                  );
                },
              ),
      ],
    );

    if (!widget.showAppBar) {
      return ColoredBox(
        color: AppColors.grey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            tabBar,
            Expanded(child: tabViews),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: GradientAppBar(
        title: 'Partner Requests',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: tabBar,
        ),
      ),
      body: tabViews,
    );
  }

  void _acceptRequest(BuildContext context, RequestModel request) {
    final bool accepted =
        ref.read(requestsProvider.notifier).acceptIncoming(request.id);

    if (!accepted) {
      _showSnackBar(
        context,
        'You already accepted a partner with another user.',
      );
      return;
    }

    _showSnackBar(context, 'Team formed! You are now locked.');
  }

  Future<void> _withdrawAcceptedRequest(
    BuildContext context,
    RequestModel request,
  ) async {
    ref.read(requestsProvider.notifier).withdrawAcceptedPartner(request.id);

    _showSnackBar(context, 'Partnership withdrawn successfully.');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  const _IncomingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    this.onWithdraw,
  });

  final RequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final bool isPending = request.status == 'pending';
    final bool isAccepted = request.status == 'accepted';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Avatar(name: request.senderName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      request.senderName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _DeptChip(label: request.senderDept),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          if (isPending)
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Accept \u2713',
                    onPressed: onAccept,
                  ),
                ),
              ],
            )
          else
            Row(
              children: <Widget>[
                _StatusBadge(status: request.status),
                if (isAccepted && onWithdraw != null) ...<Widget>[
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: onWithdraw,
                    child: Text(
                      'Withdraw',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          if (isAccepted)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'You are now locked with this teammate.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SentRequestCard extends StatelessWidget {
  const _SentRequestCard({
    required this.request,
    this.onCancel,
  });

  final RequestModel request;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Avatar(name: request.receiverName),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request.receiverName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
              _StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
          if (request.status == 'pending') ...<Widget>[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color textColor;
    late final Color backgroundColor;

    switch (status) {
      case 'accepted':
        textColor = AppColors.success;
        backgroundColor = const Color(0xFFD1FAE5);
        break;
      case 'rejected':
        textColor = AppColors.error;
        backgroundColor = const Color(0xFFFEE2E2);
        break;
      case 'withdrawn':
        textColor = const Color(0xFF6B7280);
        backgroundColor = const Color(0xFFE5E7EB);
        break;
      default:
        textColor = const Color(0xFFB45309);
        backgroundColor = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          getInitials(name),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

}

class _DeptChip extends StatelessWidget {
  const _DeptChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}
