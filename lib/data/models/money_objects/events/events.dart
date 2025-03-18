import 'package:money/data/models/money_objects/events/event.dart';
import 'package:money/data/storage/data/data.dart';

// Exports
export 'package:money/data/models/money_objects/loan_payments/loan_payment.dart';

class Events extends MoneyObjects<Event> {
  Events() {
    collectionName = 'LoanPayments';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(Event.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {}

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(getListSortedById());
  }

  Event addNewEvent() {
    // add a new Category
    final Event event = Event(
      id: -1,
      name: 'New event',
      dateBegin: DateTime.now(),
      dateEnd: DateTime.now(),
      people: '',
      memo: '',
    );

    Data().events.appendNewMoneyObject(event);
    return event;
  }
}
