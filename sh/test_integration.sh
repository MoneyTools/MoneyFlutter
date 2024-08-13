#!/bin/bash

flutter test integration_test --coverage  --coverage-path=coverage/lcov_integration.info -d macos || exit 1

flutter test --coverage --coverage-path=coverage/lcov_units.info || exit 1

lcov -a coverage/lcov_integration.info -a coverage/lcov_units.info -o coverage/lcov.info

genhtml -q coverage/lcov.info -o coverage/html > coverage/cc.txt
cat coverage/cc.txt

open coverage/html/index.html