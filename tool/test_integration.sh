#!/bin/bash

# flutter test integration_test --coverage  --coverage-path=coverage/lcov_integration.info -d linux || exit 1

flutter test --coverage --coverage-path=coverage/lcov_units.info || exit 1

# Use only unit test coverage for now
lcov -r coverage/lcov_units.info '/usr/*' -o coverage/lcov.info # Remove SDK coverage
# lcov -a coverage/lcov_integration.info -a coverage/lcov_units.info -o coverage/lcov.info

genhtml --css-file coverage/genhtml.css  -q coverage/lcov.info -o coverage/html > coverage/cc.txt

# keep the file cc.txt in git log, but also display it to the user
cat coverage/cc.txt

open coverage/html/index.html