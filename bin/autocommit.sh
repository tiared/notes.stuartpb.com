#! /usr/bin/env bash
set -e

TIMER=10

roll_index () {
  # while there are unstaged changes
  while git status --porcelain | grep -q '^.[^ ]'; do
    echo -n '.'
    git add -A
    sleep "$TIMER"
  done
}

autocommit () {
  dirt=$(git ls-files -dmo --exclude-standard)
  if [[ -n "$dirt" ]]; then
    echo -n 'Building commit..'
    roll_index
    echo
    git commit -m "$($(dirname "$0")/../vendor/git-slum --staged)" &&
      git push -f
  fi
}

autocommit
while sleep "$TIMER"; do autocommit; done
