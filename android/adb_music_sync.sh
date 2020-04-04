#!/usr/bin/env sh
set -o nounset
set -o pipefail
IFS=$'\n\t'

music_list=${1?music list is required}
music_root="/Users/mecha/Music/iTunes/iTunes Media/Music"
device_folder="/sdcard/Music"
while read -r line
do
  folder=$(echo $line | cut -d"/" -f2)
  file="$music_root/$line"
  adb push "$file" "$device_folder/$folder/"
done < "$music_list"
