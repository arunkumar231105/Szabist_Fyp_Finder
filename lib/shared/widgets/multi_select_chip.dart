import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';

class MultiSelectChip extends StatelessWidget {
  const MultiSelectChip({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((String option) {
        final bool isSelected = selected.contains(option);

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : AppColors.lightPurple,
            borderRadius: BorderRadius.circular(50),
          ),
          child: FilterChip(
            label: Text(option),
            selected: isSelected,
            showCheckmark: false,
            side: BorderSide.none,
            backgroundColor: Colors.transparent,
            selectedColor: Colors.transparent,
            disabledColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            labelStyle: GoogleFonts.poppins(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (bool value) {
              final List<String> updated = List<String>.from(selected);
              if (value) {
                if (!updated.contains(option)) {
                  updated.add(option);
                }
              } else {
                updated.remove(option);
              }
              onChanged(updated);
            },
          ),
        );
      }).toList(),
    );
  }
}
