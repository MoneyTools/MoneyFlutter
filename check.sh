#!/bin/sh

./format.sh

echo --- Analyze
dart analyze
flutter analyze

flutter test

./layers.sh

./graph.sh