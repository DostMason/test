#!/bin/bash

CONFIG_DIR="./config"

fix_file() {
  file="$1"

  [[ "$file" == *"ASF.json" ]] && return

  if grep -q '"RemoteCommunication"' "$file"; then
    sed -i 's/"RemoteCommunication":[ ]*[0-9]\+/"RemoteCommunication": 0/g' "$file"
  else
    sed -i '1s/{/{\n  "RemoteCommunication": 0,/' "$file"
  fi

  echo "Updated: $file"
}

# Run once for existing files
for file in "$CONFIG_DIR"/*.json; do
  [[ -f "$file" ]] && fix_file "$file"
done

echo "Watching for new bots..."

# Watch for new files being created
inotifywait -m -e create --format '%f' "$CONFIG_DIR" | while read FILE
do
  if [[ "$FILE" == *.json ]]; then
    sleep 1  # wait to ensure file is fully written
    fix_file "$CONFIG_DIR/$FILE"
  fi
done
