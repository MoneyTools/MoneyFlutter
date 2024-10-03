#!/bin/sh
echo --- Analyze

tool/style.sh

dart analyze 
dart fix --apply

flutter analyze

dart format . -l 120

flutter test

# layers dependencies
git@github.com:jpdup/glad.git --view layers --lines curve --align left -o layers.svg

# call graph
tool/graph.sh

