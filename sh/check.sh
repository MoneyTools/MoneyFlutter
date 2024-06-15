#!/bin/sh

./format.sh

echo --- Analyze
dart analyze
flutter analyze

flutter test

git@github.com:jpdup/glad.git --view layers --lines curve --align left -o layers.svg

./graph.sh