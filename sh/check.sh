#!/bin/sh
echo --- Analyze

dart analyze 
dart fix --apply

flutter analyze

dart format . -l 120

flutter test

git@github.com:jpdup/glad.git --view layers --lines curve --align left -o layers.svg

./graph.sh