import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  
  const PaginationControls({super.key, required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text('Page $currentPage of $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}

