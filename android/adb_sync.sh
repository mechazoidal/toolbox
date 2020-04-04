#!/usr/bin/env sh
set -o nounset
set -o pipefail
IFS=$'\n\t'

source=${1?source is required(/sdcard/<directory>}
target=${2?target is required(local path)}
#TYPES=

if [ ! -d "$target" ]
then
  echo "target must be a directory"
  exit 1
fi

for extension in jpg mp4 jpeg png gif 3gpp JPG
do
  path="$source/*.$extension"
  files=$(adb shell ls /sdcard/$path)
  for file in $files
  do
    adb pull -a "$file" "$target"
  done
done
