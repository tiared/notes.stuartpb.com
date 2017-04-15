#! /usr/bin/env bash

TIMER=300

autocommit () {
  if ! git diff-index --quiet HEAD -- ; then
    git add -A && git commit -m 'autocommit' && git push -f
  fi
}

autocommit
while sleep "$TIMER"; do autocommit; done
