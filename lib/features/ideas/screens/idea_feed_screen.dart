import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../shared/models/idea_model.dart';
import '../../../shared/providers/idea_provider.dart';
import '../../../shared/providers/request_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/idea_card.dart';

class IdeaFeedScreen extends ConsumerStatefulWidget {
  const IdeaFeedScreen({
    this.showAppBar = true,
    super.key,
  });

  final bool showAppBar;

  @override
  ConsumerState<IdeaFeedScreen> createState() => _IdeaFeedScreenState();
}

class _IdeaFeedScreenState extends ConsumerState<IdeaFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<IdeaModel> allIdeas = ref.watch(ideaProvider);
    final RequestsState requestsState = ref.watch(requestsProvider);
    final List<IdeaModel> visibleIdeas = allIdeas.where((IdeaModel idea) {
      final String query = _query.toLowerCase();
      return query.isEmpty ||
          idea.title.toLowerCase().contains(query) ||
          idea.description.toLowerCase().contains(query);
    }).toList();

    final Widget body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _searchController,
            onChanged: (String value) {
              setState(() => _query = value.trim());
            },
            decoration: InputDecoration(
              hintText: 'Search ideas...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: visibleIdeas.isEmpty
                ? Center(
                    child: Text(
                      'No ideas found yet',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: visibleIdeas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final IdeaModel idea = visibleIdeas[index];
                      return IdeaCard(
                        idea: idea,
                        onApply: () {
                          if (!requestsState.canCreateNewRequest) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You already have a pending or accepted partner request.',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Request sent! \u2728',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return ColoredBox(color: AppColors.grey, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: GradientAppBar(
        title: 'FYP Ideas \u{1F4A1}',
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push('/post-idea'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: body,
    );
  }
}
