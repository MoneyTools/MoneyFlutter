@echo off
echo --- Formatting
call flutter format . -l 222
echo --- Checking for unused code
call flutter pub run dart_code_metrics:metrics check-unused-code lib