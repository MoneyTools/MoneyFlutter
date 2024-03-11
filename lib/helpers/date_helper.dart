import 'package:intl/intl.dart';

String dateToString(final DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
