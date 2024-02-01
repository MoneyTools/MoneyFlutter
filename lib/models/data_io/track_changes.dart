import 'package:money/models/settings.dart';

/// Tracking changes of data
class TrackChanges {
  int numberOfChangesAdded = 0;
  int numberOfChangesDeleted = 0;

  int numberOfChanges() {
    return numberOfChangesAdded + numberOfChangesDeleted;
  }

  void increaseNumberOfChanges({
    int increaseAdded = 0,
    int increaseDeleted = 0,
  }) {
    numberOfChangesAdded += increaseAdded;
    numberOfChangesDeleted += increaseDeleted;
    Settings().fireOnChanged();
  }

  /// Indicate of any data has changed Added or Deleted
  bool hasChanged() {
    return numberOfChanges() > 0;
  }
}
