import 'package:flutter/material.dart';
import 'blog_theme.dart';

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const CategoryChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(text),
    selected: selected,
    onSelected: (_) => onTap(),
    labelStyle: TextStyle(
      color: selected ? blogOrange : blogMuted,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    ),
  );
}
