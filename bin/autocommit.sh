#! /usr/bin/env bash

TIMER=10

autocommit () {
  if ! git diff-index --quiet HEAD -- ; then
    git add -A &&
      git commit -m "$($(dirname "$0")/../vendor/git-slum --staged)" &&
      git push -f
  fi
}

autocommit
while sleep "$TIMER"; do autocommit; done
