#!/usr/bin/env sh
set -o nounset
set -o pipefail
IFS=$'\n\t'

device_folder=${1?device folder is required}
target_folder=${2?target is required}

files=$(adb shell ls "$device_folder/*")

# TODO keep track of potential failed downloads vs original list?
#echo "$files"
for file in $files
do
  adb pull -a "$file" "$target_folder"
done
