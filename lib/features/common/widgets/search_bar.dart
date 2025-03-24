import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;
  
  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

