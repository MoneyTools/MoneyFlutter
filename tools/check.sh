#!/bin/sh
echo --- Analyze
# dart format .
dart fix --apply

dart analyze 
flutter analyze

flutter test

# layers dependencies
git@github.com:jpdup/glad.git --view layers --lines curve --align left -o layers.svg

# call graph
tools/graph.sh

# layer diagram
tools/layers.sh

