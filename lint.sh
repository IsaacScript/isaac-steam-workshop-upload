#!/bin/bash

set -euo pipefail # Exit on errors and undefined variables.

# Get the directory of this script:
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SECONDS=0

cd "$DIR"

# Use Prettier to check formatting.
# "--log-level warn" makes it only output errors.
npx prettier --log-level warn --check .

# Spell check every file using CSpell.
# "--no-progress" and "--no-summary" make it only output errors.
npx cspell --no-progress --no-summary .

# Check for unused CSpell words.
npx cspell-check-unused-words

# Check for base file updates.
npx isaacscript check-ts --ignore ".eslintrc.cjs,build.ts,extensions.json,ci.yml,knip.jsonc,lint.ts,tsconfig.json,tsconfig.eslint.json"

echo "Successfully linted in $SECONDS seconds."
