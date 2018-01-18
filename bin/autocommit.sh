#! /usr/bin/env bash
set -e

TIMER=10

autocommit () {
  dirt=$(git ls-files -dmo --exclude-standard)
  if [[ -n "$dirt" ]]; then
    git add -A &&
      git commit -m "$($(dirname "$0")/../vendor/git-slum --staged)" &&
      git push -f
  fi
}

autocommit
while sleep "$TIMER"; do autocommit; done
