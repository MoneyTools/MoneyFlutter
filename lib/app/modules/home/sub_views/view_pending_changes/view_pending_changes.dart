import 'package:flutter/material.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/working.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/data/storage/data/data.dart';

class PendingChanges extends StatefulWidget {
  const PendingChanges({super.key});

  @override
  State<PendingChanges> createState() => _PendingChangesState();

  static void show(final BuildContext context) {
    adaptiveScreenSizeDialog(
      context: context,
      title: 'Pending Changes',
      captionForClose: 'Close',
      child: const SizedBox(
        width: 600,
        height: 900,
        child: PendingChanges(),
      ),
      actionButtons: [
        DialogActionButton(
            text: 'Save to SQL',
            onPressed: () {
              DataController.to.onSaveToSql();
              Navigator.of(context).pop(true);
            }),
        DialogActionButton(
            text: 'Save to CSV',
            onPressed: () {
              DataController.to.onSaveToCsv();
              Navigator.of(context).pop(true);
            }),
      ],
    );
  }
}

class _PendingChangesState extends State<PendingChanges> {
  bool _isLoading = true;

  final List<Mutations> _data = [
    Mutations(
      typeOfMutation: MutationType.inserted,
      title: 'Added',
      color: Colors.green,
    ),
    Mutations(
      typeOfMutation: MutationType.changed,
      title: 'Modified',
      color: Colors.orange,
    ),
    Mutations(
      typeOfMutation: MutationType.deleted,
      title: 'Deleted',
      color: Colors.red,
    ),
  ];

  int _displayMutationType = 0; // 0=Added, 1=Modified, 2=Deleted

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    for (final Mutations m in _data) {
      m.initMutationList();
    }
    setState(() {
      _isLoading = false;

      // default to what segment
      for (int i = 0; i < _data.length; i++) {
        if (_data[i].count > 0) {
          _displayMutationType = i;
          break;
        }
      }
    });
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
        Expanded(child: _buildListOfDetailsOfSelectedGroup(selectedMutationType)),
      ],
    );
  }

  Widget _buildColumnSelection() {
    return Center(
      child: SegmentedButton<int>(
        // style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
        segments: <ButtonSegment<int>>[
          _buildSegment(0, _data[0]),
          _buildSegment(1, _data[1]),
          _buildSegment(2, _data[2]),
        ],
        selected: {_displayMutationType},
        onSelectionChanged: (final Set<int> newSelection) {
          setState(() {
            _displayMutationType = newSelection.first;
          });
        },
      ),
    );
  }

  ButtonSegment<int> _buildSegment(final int id, Mutations mutations) {
    return ButtonSegment<int>(
      value: id,
      label: SizedBox(
          width: 120,
          child: Badge(
              backgroundColor: mutations.color,
              label: Text(
                getIntAsText(mutations.count),
              ),
              alignment: Alignment.centerRight,
              offset: const Offset(-30, 0),
              child: Text(mutations.title))),
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

  Widget _buildListOfDetailsOfSelectedGroup(Mutations mutations) {
    if (mutations.selectedGroup >= mutations.mutationGroups.length) {
      return const Text('No mutations');
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
}

class Mutations {
  MutationType typeOfMutation;
  String title;
  Color color;
  int count = 0;
  int selectedGroup = 0;

  List<MutationGroup> mutationGroups = [];

  Mutations({
    required this.typeOfMutation,
    required this.title,
    required this.color,
  });

  void initMutationList() {
    count = 0;
    mutationGroups = Data().getMutationGroups(typeOfMutation);

    for (final m in mutationGroups) {
      count += m.whatWasMutated.length;
    }
  }
}
