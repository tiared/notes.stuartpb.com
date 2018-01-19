#! /usr/bin/env bash
set -e

# Times to wait.

# How frequently to check if the working tree has changed.
POLL=1
# How long to wait for changes to settle before cutting a commit.
SETTLE=5

roll_index () {
  # while there are unstaged changes
  while git status --porcelain | grep -q '^.[^ ]'; do
    echo -n '.'
    git add -A
    sleep "$SETTLE"
  done
}

autocommit () {
  dirt=$(git ls-files -dmo --exclude-standard)
  if [[ -n "$dirt" ]]; then
    echo
    echo -n 'Building commit..'
    roll_index
    echo
    git commit -m "$($(dirname "$0")/../vendor/git-slum --staged)" &&
      git push -f
  fi
}

DANCESTEP=0
DANCEMOVES=(
  $'\e[1;93m'"(>'-')>"$'\e[0m'
  $'\e[1;93m'"<('-'<)"$'\e[0m')

autocommit
while sleep "$POLL"; do
  echo -n $'\r'"Watching for changes... ${DANCEMOVES[DANCESTEP]} "
  DANCESTEP=$(((DANCESTEP + 1) % ${#DANCEMOVES[@]}))
  autocommit
done
