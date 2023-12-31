@echo off

echo --- Fix
dart fix --apply

echo --- Formatting
dart format . -l 120

echo --- Analyze
flutter analyze