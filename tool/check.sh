#!/bin/sh
echo --- Analyze
dart fix --apply
dart format .

dart analyze 
flutter analyze

flutter test

# layers dependencies
git@github.com:jpdup/glad.git --view layers --lines curve --align left -o layers.svg

# call graph
tool/graph.sh

# layer diagram
tool/layers.sh

