class DateRange {
  DateTime? min;
  DateTime? max;

  DateRange() {
    //
  }

  inflate(DateTime dateTime) {
    min ??= dateTime;
    max ??= dateTime;

    if (dateTime.compareTo(min!) == -1) {
      min = dateTime;
    }

    if (dateTime.compareTo(max!) == 1) {
      max = dateTime;
    }
  }

  valueOrZeroIfNull(value){
    if(value==null){
      return 0;
    }
    return value;
  }

  durationInYears() {
    if(min==null || max==null){
      return 0;
    }

    return (valueOrZeroIfNull(max!.year) - valueOrZeroIfNull(min!.year)) + 1;
  }

  @override
  toString() {
    return dateToString(min) + " : " + dateToString(max);
  }

  toStringYears() {
    return yearToString(min) + " - " + yearToString(max) + " (" + durationInYears().toString() + ")";
  }

  dateToString(DateTime? dateTime) {
    if (dateTime == null) {
      return "____-__-__";
    }

    return dateTime.toIso8601String();
  }

  yearToString(DateTime? dateTime) {
    if (dateTime == null) {
      return "____";
    }

    return dateTime.year.toString();
  }
}
