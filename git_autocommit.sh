#!/bin/bash
# Helper script for automating git checkins of a single respository.
# Intended use-case is for autosaved plaintext notes, i.e. vimwiki and the like.
# swf, 20120206

while getopts ":vd:" opt; do
  case $opt in
    v)
      VERBOSE=1
      ;;
    d)
      DIRECTORY=$OPTARG
      ;;
    /?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# from: http://serverfault.com/a/400419
if [ -n "`git --git-dir "$DIRECTORY/.git" --work-tree "$DIRECTORY" ls-files -m -o --exclude-standard`" ] 
then
  if [ $VERBOSE ] 
  then
    echo "gonna commit to this"
  fi

  # FIXME: should really get the list of added files w/ls-files
  # --all also records removal of files
  git --git-dir "$DIRECTORY/.git" --work-tree "$DIRECTORY" add --all .
  git --git-dir "$DIRECTORY/.git" --work-tree "$DIRECTORY" commit -m"AUTOCOMMIT" --quiet
else
  if [ $VERBOSE ] 
  then
    echo "not gonna commit just yet"
  fi
fi
