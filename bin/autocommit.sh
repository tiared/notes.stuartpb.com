#! /usr/bin/env bash
set -e

# How frequently to check if the working tree has changed.
POLL=1
# How many polls to wait for changes to settle before cutting a commit.
FUSETIME=10

autocommit () {
  git commit -m "$($(dirname "$0")/../vendor/git-slum --staged)" &&
    git push -f
}

roll_index () {
  local SHOTCLOCK
  echo
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
  echo
}

# this checks if there's any change from the working tree to HEAD
# this can be true even when all those changes are staged
# that's the main distinction between this check and the one in roll_index
check_dirty () {
  dirt=$(git ls-files -dmo --exclude-standard)
  [[ -n "$dirt" ]]
}

DANCESTEP=0
DANCEMOVES=(
  $'\e[1;93m'"^('-')^"$'\e[0m'
  $'\e[1;93m'"v('-')v"$'\e[0m')

watch_for_changes () {
  while :; do
    echo -n $'\r'"Watching for changes... ${DANCEMOVES[DANCESTEP]} "
    DANCESTEP=$(( (DANCESTEP + 1) % ${#DANCEMOVES[@]} ))
    if check_dirty; then
      roll_index
      autocommit
    fi
    sleep "$POLL"
  done
}

if check_dirty; then
  git add -A
  autocommit
fi
watch_for_changes
