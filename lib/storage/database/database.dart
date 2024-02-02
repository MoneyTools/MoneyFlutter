import 'package:money/storage/database/database_sql.dart'
    if (dart.library.html) 'package:money/models/data_io/database_web.dart';

class MyDatabase extends MyDatabaseImplementation {
  MyDatabase(super.fileToOpen);
}
