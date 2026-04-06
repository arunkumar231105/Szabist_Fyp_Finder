import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/student_card.dart';
import '../../../shared/widgets/gradient_app_bar.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late List<StudentModel> _bookmarkedStudents;

  @override
  void initState() {
    super.initState();
    _bookmarkedStudents = StudentModel.dummyList().take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: const GradientAppBar(title: 'Saved Profiles \u{1F516}'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _bookmarkedStudents.isEmpty
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
                itemCount: _bookmarkedStudents.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final StudentModel student = _bookmarkedStudents[index];
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
      _bookmarkedStudents = _bookmarkedStudents
          .where((StudentModel student) => student.id != id)
          .toList();
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
