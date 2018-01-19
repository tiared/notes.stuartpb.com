#! /usr/bin/env bash
set -e

# Times to wait.

# How frequently to check if the working tree has changed.
POLL=1
# How many polls to wait for changes to settle before cutting a commit.
FUSETIME=10

roll_index () {
  local SHOTCLOCK
  while (( SHOTCLOCK <= FUSETIME )); do
    # reset the shotclock whenever there are unstaged changes
    if git status --porcelain | grep -q '^.[^ ]'; then
      git add -A
      SHOTCLOCK=0
    fi
    echo -n $'\rBuilding commit'
    for ((i = 0; i < FUSETIME; ++i)); do
      if ((i < SHOTCLOCK)); then
        echo -n '.'
      else
        echo -n ' '
      fi
    done
    echo -n $'\e[1;31m!\e[0m'
    SHOTCLOCK=$((SHOTCLOCK + 1))
    if ((SHOTCLOCK <= FUSETIME)); then sleep "$POLL"; fi
  done
}

autocommit () {
  dirt=$(git ls-files -dmo --exclude-standard)
  if [[ -n "$dirt" ]]; then
    echo
    roll_index
    echo
    git commit -m "$($(dirname "$0")/../vendor/git-slum --staged)" &&
      git push -f
  fi
}

DANCESTEP=0
DANCEMOVES=(
  $'\e[1;93m'"^('-')^"$'\e[0m'
  $'\e[1;93m'"v('-')v"$'\e[0m')

autocommit
while sleep "$POLL"; do
  echo -n $'\r'"Watching for changes... ${DANCEMOVES[DANCESTEP]} "
  DANCESTEP=$(( (DANCESTEP + 1) % ${#DANCEMOVES[@]} ))
  autocommit
done
