import 'package:flutter/material.dart';

class CsvColumnMapperDialog extends StatefulWidget {
  final List<String> headers;
  final List<List<String>> dataRows; // First few rows for preview

  const CsvColumnMapperDialog({
    super.key,
    required this.headers,
    required this.dataRows,
  });

  @override
  State<CsvColumnMapperDialog> createState() => _CsvColumnMapperDialogState();
}

class _CsvColumnMapperDialogState extends State<CsvColumnMapperDialog> {
  String? _selectedDateColumn;
  String? _selectedDescriptionColumn;
  String? _selectedAmountColumn;

  @override
  void initState() {
    super.initState();
    // Try to pre-select based on common names, if possible, or leave null
    // For simplicity, we'll leave them null for now.
    // Users must explicitly map them.
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headers.isEmpty) {
      // Should not happen if CSV is valid and has headers
      return AlertDialog(
        title: const Text('Error'), // Keep inner Text const if possible
        content: const Text('CSV headers are missing or empty.'), // Keep inner Text const
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Map CSV Columns'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite, // Use available width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildMappingDropdowns(),
              const SizedBox(height: 20),
              const Text('CSV Data Preview (First 5 rows):', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPreviewTable(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(), // No result means cancellation
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            // TODO: Validate selections (e.g., all are selected, no duplicates if necessary)
            // For now, just print and pop with a map of selections
            if (_selectedDateColumn == null || _selectedDescriptionColumn == null || _selectedAmountColumn == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please map all fields (Date, Description, Amount).')),
              );
              return;
            }
            final mapping = {
              'date': _selectedDateColumn!,
              'description': _selectedDescriptionColumn!,
              'amount': _selectedAmountColumn!,
            };
            Navigator.of(context).pop(mapping);
          },
        ),
      ],
    );
  }

  Widget _buildMappingDropdowns() {
    return Column(
      children: [
        _buildDropdown('Date Column:', _selectedDateColumn, (newValue) {
          setState(() {
            _selectedDateColumn = newValue;
          });
        }),
        _buildDropdown('Description Column:', _selectedDescriptionColumn, (newValue) {
          setState(() {
            _selectedDescriptionColumn = newValue;
          });
        }),
        _buildDropdown('Amount Column:', _selectedAmountColumn, (newValue) {
          setState(() {
            _selectedAmountColumn = newValue;
          });
        }),
      ],
    );
  }

  Widget _buildDropdown(String label, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: currentValue,
        hint: const Text('Select column'),
        isExpanded: true,
        items: widget.headers.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPreviewTable() {
    // Displaying only up to the first 5 data rows for preview
    final previewRowCount = widget.dataRows.length > 5 ? 5 : widget.dataRows.length;
    if (previewRowCount == 0) {
      return const Text('No data rows to preview.');
    }

    return DataTable(
      columns: widget.headers.map((header) => DataColumn(label: Text(header))).toList(),
      rows: widget.dataRows.sublist(0, previewRowCount).map((row) {
        final numExpectedColumns = widget.headers.length;
        List<DataCell> cells = [];
        for (int i = 0; i < numExpectedColumns; i++) {
          if (i < row.length) {
            cells.add(DataCell(Text(row[i]))); // Cell exists
          } else {
            cells.add(DataCell(const Text(''))); // Pad with empty cell
          }
        }
        // If row.length > numExpectedColumns, extra cells in 'row' are implicitly truncated
        // because we only iterate up to numExpectedColumns.
        return DataRow(cells: cells);
      }).toList(),
    );
  }
}

// Helper function to show the dialog (optional, but good practice)
Future<Map<String, String>?> showCsvColumnMapperDialog({
  required BuildContext context,
  required List<String> headers,
  required List<List<String>> dataRows,
}) {
  return showDialog<Map<String, String>?>(
    context: context,
    barrierDismissible: false, // User must make a choice
    builder: (BuildContext context) {
      return CsvColumnMapperDialog(headers: headers, dataRows: dataRows);
    },
  );
}
