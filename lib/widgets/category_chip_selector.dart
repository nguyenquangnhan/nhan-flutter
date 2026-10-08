import 'package:flutter/material.dart';
import '../models/expense_category.dart';

class CategoryChipSelector extends StatelessWidget {
  final ExpenseCategory selectedCategory;
  final ValueChanged<ExpenseCategory> onSelected;

  const CategoryChipSelector({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseCategory.values.map((category) {
        final isSelected = category == selectedCategory;
        return ChoiceChip(
          avatar: Icon(
            category.icon,
            size: 16,
            color: isSelected ? Colors.white : category.color,
          ),
          label: Text(category.displayName),
          selected: isSelected,
          selectedColor: category.color,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            if (selected) {
              onSelected(category);
            }
          },
        );
      }).toList(),
    );
  }
}
