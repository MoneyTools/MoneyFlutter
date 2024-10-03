# install lakos - see https://pub.dev/packages/lakos/install
# dart pub global activate lakos
# export PATH="$PATH":"$HOME/.pub-cache/bin"
echo "Generate Graph dependencies"

rm graph.dot
rm graph.svg

## with folders
lakos -o graph.dot --metrics --ignore=test/** .

# remove the folders
#lakos -o graph.dot --no-tree --metrics --ignore=test/** .


dot -Tsvg graph.dot -Grankdir=TB -Gcolor=lightgray -Ecolor="#aabbaa88" -o graph.svg
#fdp -Tsvg graph.dot -Gcolor=lightgray -Ecolor="#aabbaa99" -o graph.svg
