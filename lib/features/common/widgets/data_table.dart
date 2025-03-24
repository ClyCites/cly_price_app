import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  
  const CustomDataTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columns,
      rows: rows,
    );
  }
}

