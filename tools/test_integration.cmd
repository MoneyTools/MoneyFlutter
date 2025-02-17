@echo off

call flutter test integration_test --coverage  --coverage-path=coverage/lcov_integration.info -d windows || exit 1

call flutter test --coverage --coverage-path=coverage/lcov_units.info || exit 1

rem call lcov -a coverage/lcov_integration.info -a coverage/lcov_units.info -o coverage/lcov.info

rem call genhtml --no-function-coverage --css-file coverage/genhtml.css  -q coverage/lcov.info -o coverage/html > coverage/cc.txt

rem call cat coverage/cc.txt

rem call open coverage/html/index.html