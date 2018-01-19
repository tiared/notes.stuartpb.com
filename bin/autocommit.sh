#! /usr/bin/env bash
set -e

# How frequently to check if the working tree has changed.
TICK=1
# How many ticks to wait for changes to settle before cutting a commit.
FUSETIME=10
# Dance to do while waiting for changes.
DANCEMOVES=(
  $'\e[1;93m'"^('-')^"$'\e[0m'
  $'\e[1;93m'"v('-')v"$'\e[0m')

git-slum-staged () {
  $(dirname "$0")/../vendor/git-slum --staged
}

autocommit () {
  git commit -m "$(git-slum-staged)" && git push
}

unstaged-changes () {
  git status --porcelain | grep -q '^.[^ ]'
}

uncommitted-changes () {
  local DIRT=$(git ls-files -dmo --exclude-standard)
  [[ -n "$DIRT" ]]
}

key-pressed-in-tick () {
  local _
  read -s -r -t "$TICK" -n 1 _
}

flush-input () {
  local _
  while read -r -t 0 _; do read -n 4096 -r _; done
}

roll-index () {
  local SHOTCLOCK

  flush-input

  echo
  while (( SHOTCLOCK <= FUSETIME )); do

    # reset the shotclock whenever there are unstaged changes
    if unstaged-changes; then
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
    echo -n $'\e[1;31m!\e[0m '

    SHOTCLOCK=$((SHOTCLOCK + 1))
    if ((SHOTCLOCK <= FUSETIME)); then
      if key-pressed-in-tick; then
        SHOTCLOCK=$FUSETIME
      fi
    fi

  done
  echo
}

watch-for-changes () {
  local DANCESTEP=0

  while :; do
    echo -n $'\r'"Watching for changes... ${DANCEMOVES[DANCESTEP]} "

    DANCESTEP=$(( (DANCESTEP + 1) % ${#DANCEMOVES[@]} ))

    if uncommitted-changes; then
      roll-index
      autocommit
    fi

    sleep "$TICK"
  done
}

if uncommitted-changes; then
  git add -A
  autocommit
fi
watch-for-changes
