class FieldFilter {
  final String fieldName;
  late String filterTextInLowerCase;

  FieldFilter({required this.fieldName, required this.filterTextInLowerCase}) {
    filterTextInLowerCase = filterTextInLowerCase.toLowerCase();
  }
}
