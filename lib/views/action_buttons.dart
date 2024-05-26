import 'package:flutter/material.dart';

Widget buildMergeButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.merge),
    tooltip: 'Merge item(s)',
  );
}

Widget buildAddItemButton(final Function callback, final String tooltip) {
  return IconButton(
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.add_circle_outline),
    tooltip: tooltip,
  );
}

Widget buildAddTransactionsButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.add_road),
    tooltip: 'Add a new transactions',
  );
}

Widget buildEditButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.edit),
    tooltip: 'Edit selected item(s)',
  );
}

Widget buildDeleteButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.delete),
    tooltip: 'Delete selected item(s)',
  );
}

Widget buildCopyButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.copy_all),
    tooltip: 'Copy list to clipboard',
  );
}
