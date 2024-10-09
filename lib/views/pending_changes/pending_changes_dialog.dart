import 'package:flutter/material.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/dialog/dialog.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/my_segment.dart';
import 'package:money/core/widgets/working.dart';
import 'package:money/data/storage/data/data.dart';

class PendingChangesDialog extends StatefulWidget {
  const PendingChangesDialog({super.key});

  @override
  State<PendingChangesDialog> createState() => _PendingChangesDialogState();

  static void show(final BuildContext context) {
    adaptiveScreenSizeDialog(
      context: context,
      title: 'Pending Changes',
      captionForClose: 'Close',
      child: const SizedBox(
        width: 600,
        height: 900,
        child: PendingChangesDialog(),
      ),
      actionButtons: [
        DialogActionButton(
          text: 'Save to SQL',
          onPressed: () {
            DataController.to.onSaveToSql();
            Navigator.of(context).pop(true);
          },
        ),
        DialogActionButton(
          text: 'Save to CSV',
          onPressed: () {
            DataController.to.onSaveToCsv();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

class _PendingChangesDialogState extends State<PendingChangesDialog> {
  final List<Mutations> _data = [
    Mutations(
      typeOfMutation: MutationType.inserted,
      title: 'added',
      color: Colors.green,
    ),
    Mutations(
      typeOfMutation: MutationType.changed,
      title: 'modified',
      color: Colors.orange,
    ),
    Mutations(
      typeOfMutation: MutationType.deleted,
      title: 'deleted',
      color: Colors.red,
    ),
  ];

  int _displayMutationType = 0; // 0=Added, 1=Modified, 2=Deleted
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const WorkingIndicator();
    }
    final selectedMutationType = _data[_displayMutationType];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildColumnSelection(),
        gapLarge(),
        _buildSubSegmentsButtons(selectedMutationType),
        gapLarge(),
        Expanded(
          child: _buildListOfDetailsOfSelectedGroup(selectedMutationType),
        ),
      ],
    );
  }

  Widget _buildColumnSelection() {
    return Center(
      child: mySegmentSelector(
        segments: [
          _buildSegment(0, _data[0]),
          _buildSegment(1, _data[1]),
          _buildSegment(2, _data[2]),
        ],
        selectedId: _displayMutationType,
        onSelectionChanged: (final int newSelection) {
          setState(() {
            _displayMutationType = newSelection;
          });
        },
      ),
    );
  }

  Widget _buildListOfDetailsOfSelectedGroup(Mutations mutations) {
    if (mutations.selectedGroup >= mutations.mutationGroups.length) {
      return Center(child: Text('No items were ${mutations.title}'));
    }

    final MutationGroup g = mutations.mutationGroups[mutations.selectedGroup];

    return ListView.separated(
      itemCount: g.whatWasMutated.length,
      itemBuilder: (context, index) {
        return g.whatWasMutated[index];
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
    );
  }

  ButtonSegment<int> _buildSegment(final int id, Mutations mutations) {
    return ButtonSegment<int>(
      value: id,
      label: SizedBox(
        width: 120,
        child: Text(mutations.fullTitle, textAlign: TextAlign.center, style: TextStyle(color: mutations.color)),
      ),
    );
  }

  Widget _buildSubSegmentsButtons(Mutations mutations) {
    List<Widget> groupSelectors = [];

    for (int i = 0; i < mutations.mutationGroups.length; i++) {
      final group = mutations.mutationGroups[i];
      final w = Container(
        padding: const EdgeInsets.only(bottom: 4),
        child: Badge(
          backgroundColor: mutations.color,
          label: Text(
            getIntAsText(group.whatWasMutated.length),
          ),
          child: InputChip(
            label: Text(group.title),
            selected: i == mutations.selectedGroup,
            onSelected: (bool value) {
              setState(() {
                mutations.selectedGroup = i;
              });
            },
          ),
        ),
      );

      groupSelectors.add(w);
    }

    return Wrap(spacing: 10, runSpacing: 10, children: groupSelectors);
  }

  void _load() {
    for (final Mutations m in _data) {
      m.initMutationList();
    }
    setState(() {
      _isLoading = false;

      // default to the first segment that has a count
      for (int i = 0; i < _data.length; i++) {
        if (_data[i].count > 0) {
          _displayMutationType = i;
          break;
        }
      }
    });
  }
}

class Mutations {
  Mutations({
    required this.typeOfMutation,
    required this.title,
    required this.color,
  });

  Color color;
  int count = 0;
  List<MutationGroup> mutationGroups = [];
  int selectedGroup = 0;
  String title;
  MutationType typeOfMutation;

  String get fullTitle {
    if (count == 0) {
      return 'None $title';
    }
    return '${getIntAsText(count)} $title';
  }

  void initMutationList() {
    count = 0;
    mutationGroups = Data().getMutationGroups(typeOfMutation);

    for (final m in mutationGroups) {
      count += m.whatWasMutated.length;
    }
  }
}
