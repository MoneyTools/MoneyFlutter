import 'package:money/storage/database/data_others.dart'
    if (dart.library.html) 'package:money/models/data_io/data_web.dart';

class MyDatabase extends MyDatabaseImplementation {
  MyDatabase(super.fileToOpen);
}
