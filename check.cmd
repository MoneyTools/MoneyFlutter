@echo off

echo --- Fix
dart fix --apply

echo --- Formatting
call flutter format . -l 222

echo --- Analyze
flutter analyze