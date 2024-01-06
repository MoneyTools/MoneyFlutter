#!/bin/bash

if which node >/dev/null; then
  node_version=$(node -v)
  echo "Found Node.js version: $node_version"
  npx git@github.com:jpdup/glad.git -l --view layers --align left -o layers.svg
  open ./layers.svg
else
  echo "Node.js is not installed."
  echo "To install use brew"
  echo "brew install node"
fi


