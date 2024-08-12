#!/bin/bash

rm coverage/lcov1.info &> /dev/null
rm coverage/lcov2.info &> /dev/null
rm coverage/lcov.info &> /dev/null

flutter test integration_test --coverage -d macos
mv coverage/lcov.info coverage/lcov1.info

flutter test --coverage 
mv coverage/lcov.info coverage/lcov2.info

lcov -a coverage/lcov1.info -a coverage/lcov2.info -o coverage/lcov.info

genhtml -q coverage/lcov.info -o coverage/html > coverage/cc.txt
cat coverage/cc.txt

open coverage/html/index.html