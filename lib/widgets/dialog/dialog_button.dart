import 'package:flutter/material.dart';
import 'package:money/widgets/widgets.dart';

class DialogActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DialogActionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

Widget dialogActionButtons(final List<Widget> actionsButtons) {
  return Wrap(
    alignment: WrapAlignment.end,
    spacing: 10,
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
    icon: const Icon(Icons.post_add_outlined),
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

class InternalViewSwitching {
  final IconData? icon;
  final String title;
  final Function callback;

  InternalViewSwitching(this.icon, this.title, this.callback);
}

Widget buildJumpToButton(final List<InternalViewSwitching> listOfViewToJumpTo) {
  final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
  for (var i = 0; i < listOfViewToJumpTo.length; i++) {
    list.add(
      PopupMenuItem<int>(
        value: i,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ThreePartLabel(
                icon: Icon(listOfViewToJumpTo[i].icon),
                text1: listOfViewToJumpTo[i].title,
                small: true,
              ),
            ),
            const Icon(Icons.menu_open_outlined),
          ],
        ),
      ),
    );
  }
  return myPopupMenuIconButton(
      icon: Icons.open_in_new_outlined,
      tooltip: 'Switch view',
      list: list,
      onSelected: (final index) {
        listOfViewToJumpTo[index].callback();
      });
}

PopupMenuButton<int> myPopupMenuIconButton({
  required final IconData icon,
  required final String tooltip,
  required final List<PopupMenuItem<int>> list,
  required final Function(int) onSelected,
}) {
  return PopupMenuButton<int>(
    icon: Icon(icon),
    tooltip: tooltip,
    position: PopupMenuPosition.under,
    itemBuilder: (final BuildContext context) {
      return list;
    },
    onSelected: onSelected,
  );
}
