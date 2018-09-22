#! /usr/bin/env bash

if [[ -d content ]]; then
  root=content/
fi

for file in *.md
do if [[ $file != [A-Z]* ]]; then
  export newname=$(uuidgen).md
  echo "- [$file][]" >> LIST.md
  echo "[$file]: $root$newname" >> LINKS.md
  git mv "$file" "$root$newname"
fi; done
