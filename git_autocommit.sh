#!/bin/bash
# Helper script for automating git checkins of a single respository.
# Intended use-case is for autosaved plaintext notes, i.e. vimwiki and the like.
# swf, 20120206

while getopts ":vad:" opt; do
  case $opt in
    v)
      VERBOSE=1
      ;;
    d)
      DIRECTORY=$OPTARG
      ;;
    a)
      MAKE_ARCHIVE=1
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
# -m : get list of all modified files since last commit
# -o : show untracked files
# --exclude-standard : takes .gitignore and .git/info/exclude into account when building the list
# --git-dir & --work-tree : must specify these when running from cronjob
if [ -n "`git --git-dir "$DIRECTORY/.git" --work-tree "$DIRECTORY" ls-files -m -o --exclude-standard`" ] 
then
  if [ $VERBOSE ] 
  then
    echo "gonna commit to this"
  fi

  # --all also records removal of files
  git --git-dir "$DIRECTORY/.git" --work-tree "$DIRECTORY" add --all .
  git --git-dir "$DIRECTORY/.git" --work-tree "$DIRECTORY" commit -m"AUTOCOMMIT" --quiet
  # UNTESTED
  if [ $MAKE_ARCHIVE ]
  then
    date=$(date "+%Y%m%d")
    git archive --format=zip --prefix="$DIRECTORY/" HEAD > "$HOME/Desktop/$DIRECTORY_$date.zip"
  fi
else
  if [ $VERBOSE ] 
  then
    echo "not gonna commit just yet"
  fi
fi
