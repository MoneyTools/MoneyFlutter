#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <pdf_file_path>"
    exit 1
fi

# Convert PDF to images
pdftoppm -r 400 "$1" output
rm output-pages.txt
# Process the images using tesseract
for img in $(ls output*.ppm | sort -V); do
    tesseract "$img" "output-$(basename "$img" .ppm)"
    cat "output-$(basename "$img" .ppm).txt" >> output-pages.txt
    rm "output-$(basename "$img" .ppm).txt"
done

# Open the output file
code output-pages.txt
