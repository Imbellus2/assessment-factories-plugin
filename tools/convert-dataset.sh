#!/bin/bash
echo "Converting"
DIR=$(
    cd "$(dirname "$0")"
    pwd
)
cd $DIR/..

# Check if the argument is provided
if [ -z "$1" ]; then
    echo "Please provide the dataset name as an argument."
    exit 1
fi

# Suffix provided as the first argument
suffix="$1"

# Original file name
original_file="src/data/dataset_${suffix}.lua"

# New file name
new_file="src/data/dataset_${suffix}.json"
# Check if the original file exists
if [ -e "$original_file" ]; then
    # Copy the file and change the extension
    cp "$original_file" "$new_file"
    echo "File copied and extension changed successfully."
else
    echo "File not found."
    exit 1
fi
