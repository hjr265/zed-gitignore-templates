#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/github/gitignore.git"
DIR_NAME="gitignore"

TEMP_FILE="tmp.json"
OUT_FILE="snippets/git ignore.json"

while getopts "l" opt; do
    case $opt in
        l)
            FLAG_LOCAL_ONLY=true
            ;;
        *)
            echo "Usage: $0 [-l]"
            exit 1
            ;;
    esac
done

if [ -d "$DIR_NAME" ]; then
    if [ -z "$FLAG_LOCAL_ONLY" ]; then
        echo "Directory '$DIR_NAME' already exists. Pulling changes..."
        cd "$DIR_NAME" || exit
        git pull origin main # Update the repository
        cd ..
    else
        echo "Skipping update due to -l flag."
    fi
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$DIR_NAME" # Clone the repository
fi

echo "{" > "$TEMP_FILE"
for file in "$DIR_NAME"/*.gitignore; do
    # Check if the file exists
    if [ -f "$file" ]; then
        FILENAME=$(basename "$file")
        CONTENTS=$(<"$file")
        BODY=$(echo "$CONTENTS" | jq -Rs .)
        echo "  \"Use $FILENAME\": {\"prefix\": \"$FILENAME\", \"body\": [$BODY, \"\$0\"]}," >> "$TEMP_FILE"
    fi
done
sed -i '$ s/,$//' "$TEMP_FILE" # Remove the last comma
echo "}" >> "$TEMP_FILE"

jq . "$TEMP_FILE" > "$OUT_FILE"
rm "$TEMP_FILE"

echo "JSON file '$OUT_FILE' created successfully."
