import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/students_provider.dart';
import '../../../shared/widgets/student_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  // Local bookmark set — tracks which student IDs are bookmarked
  late Set<String> _bookmarkedIds;

  @override
  void initState() {
    super.initState();
    // Pre-seed with first 3 students once provider loads (updated in build)
    _bookmarkedIds = {};
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = ref.watch(studentsProvider);

    // On first load seed bookmarks with first 3 real students
    if (_bookmarkedIds.isEmpty && allStudents.isNotEmpty) {
      _bookmarkedIds = allStudents.take(3).map((s) => s.id).toSet();
    }

    final List<StudentModel> bookmarkedStudents = allStudents
        .where((s) => _bookmarkedIds.contains(s.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: const GradientAppBar(title: 'Saved Profiles 🔖'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: bookmarkedStudents.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: AppColors.lightPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved profiles yet',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: bookmarkedStudents.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final StudentModel student = bookmarkedStudents[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: StudentCard(
                          student: student,
                          onTap: () => context.push('/profile/${student.id}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFFEF4444),
                              Color(0xFFF97316),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () => _removeBookmark(student.id),
                          icon: const Icon(
                            Icons.bookmark_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  void _removeBookmark(String id) {
    setState(() {
      _bookmarkedIds = Set.from(_bookmarkedIds)..remove(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed from bookmarks',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
