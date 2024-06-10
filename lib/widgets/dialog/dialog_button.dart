import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';

class DialogActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DialogActionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

Widget dialogActionButtons(final List<Widget> actionsButtons) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: actionsButtons,
  );
}

Widget buildMergeButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.merge_outlined),
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
    icon: const Icon(Icons.edit_outlined),
    tooltip: 'Edit selected item(s)',
  );
}

Widget buildDeleteButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.delete_outline),
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

Widget buildJumpToButton(final List<Pair<String, Function>> listOfViewToJumpTo) {
  final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
  for (var i = 0; i < listOfViewToJumpTo.length; i++) {
    list.add(PopupMenuItem<int>(
      value: i,
      child: Text(listOfViewToJumpTo[i].first),
    ));
  }
  return PopupMenuButton<int>(
    icon: const Icon(Icons.open_in_new_outlined),
    itemBuilder: (final BuildContext context) {
      return list;
    },
    onSelected: (final int index) {
      listOfViewToJumpTo[index].second.call();
    },
  );
}
