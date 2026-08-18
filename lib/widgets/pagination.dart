import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageButton(
            context,
            '‹',
            currentPage > 1,
            () => onPageChanged(currentPage - 1),
            isDark,
          ),
          ..._getPageNumbers().map((page) {
            if (page == -1) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(fontSize: 14)),
              );
            }
            final isSelected = page == currentPage;
            return _buildPageButton(
              context,
              page.toString(),
              true,
              () => onPageChanged(page),
              isDark,
              isSelected: isSelected,
            );
          }).toList(),
          _buildPageButton(
            context,
            '›',
            currentPage < totalPages,
            () => onPageChanged(currentPage + 1),
            isDark,
          ),
        ],
      ),
    );
  }

  List<int> _getPageNumbers() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final pages = <int>[];
    pages.add(1);

    if (currentPage > 3) {
      pages.add(-1);
    }

    final start = currentPage > 3 ? currentPage - 1 : 2;
    final end = currentPage < totalPages - 2 ? currentPage + 1 : totalPages - 1;

    for (int i = start; i <= end && i <= totalPages; i++) {
      if (i > 1 && i < totalPages) {
        pages.add(i);
      }
    }

    if (currentPage < totalPages - 2) {
      pages.add(-1);
    }

    if (totalPages > 1) {
      pages.add(totalPages);
    }

    return pages;
  }

  Widget _buildPageButton(
    BuildContext context,
    String text,
    bool enabled,
    VoidCallback onTap,
    bool isDark, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C5CE7)
              : (isDark ? const Color(0xFF1A1A2E) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C5CE7)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (enabled
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}