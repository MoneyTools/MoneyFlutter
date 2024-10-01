@echo off

echo --- Analyze
call dart analyze

echo --- Fix
call dart fix --apply

echo --- Formatting
call dart format . -l 120

call flutter test
