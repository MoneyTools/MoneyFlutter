/// Tracking changes of data
class DataMutations {
  int added = 0;
  int changed = 0;
  int deleted = 0;

  int numberOfChanges() {
    return added + changed + deleted;
  }

  /// Indicate of any data has changed Added or Deleted
  bool hasChanged() {
    return numberOfChanges() > 0;
  }

  void increaseNumber({
    int increaseAdded = 0,
    int increaseChanged = 0,
    int increaseDeleted = 0,
  }) {
    added += increaseAdded;
    changed += increaseChanged;
    deleted += increaseDeleted;
  }

  void reset() {
    added = 0;
    changed = 0;
    deleted = 0;
  }
}
