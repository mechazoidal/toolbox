#!/usr/bin/env bash
set -o nounset
set -o pipefail
IFS=$'\n\t'

OUTDIR=${1:-}
if [[ -z "$OUTDIR" ]]; then
  OUTDIR="$HOME/Desktop/temp_photos/camera/"
fi


photos=$(adb shell ls /sdcard/DCIM/Camera/*.jpg)
videos=$(adb shell ls /sdcard/DCIM/Camera/*.mp4)
# FIXME not sure how to get a combined list of all textra locations using adb shell commands
#sms_photos=$(cat <(adb shell ls /sdcard/Textra/Media/Textra/*.jpg) <(adb shell ls /sdcard/Textra/Media/Textra/*.JPG))
#sms_photos=$TEMPDIR/sms_photos
#cat <(adb shell ls /sdcard/Textra/Media/Textra/*.jpg) <(adb shell ls /sdcard/Textra/Media/Textra/*.JPG) > sms_photos
#target="$HOME/Desktop/Pending Photos/"
# TODO keep track of potential failed downloads vs original list?

# TODO check if file is already there before `pull`ing
for photo in $photos
do
  adb pull -a "$photo" "$OUTDIR"
done

for vid in $videos
do
  adb pull -a "$vid" "$OUTDIR"
done
