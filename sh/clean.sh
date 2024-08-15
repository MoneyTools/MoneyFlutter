#!/bin/sh

# rm -R ./build

flutter clean
flutter pub get

rm test_output_sqlite.db
rm flutter_*.log