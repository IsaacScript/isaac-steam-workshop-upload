#!/bin/bash

set -e # Exit on any errors

# Get the directory of this script:
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SECONDS=0

cd "$DIR"

# Use Prettier to check formatting.
npx prettier --check .

# Spell check every file using cspell.
# We use "--no-progress" and "--no-summary" because we want to only output errors.
npx cspell --no-progress --no-summary .

# Check for orphaned words.
bash "$DIR/check-orphaned-words.sh"

# Check for base file updates.
npx zamts check

echo "Successfully linted in $SECONDS seconds."
