import 'package:flutter/material.dart';

import '../../core/colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bottom,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      ),
    );
  }
}
