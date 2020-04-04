#!/usr/bin/env sh
target=${1?target is required}
images1=$(adb shell ls /sdcard/Download/*.jpg)
images2=$(adb shell ls /sdcard/Download/*.jpeg)
images3=$(adb shell ls /sdcard/Download/*.png)
images4=$(adb shell ls /sdcard/Download/*.gif)
videos=$(adb shell ls /sdcard/Download/*.mp4)
# TODO keep track of potential failed downloads vs original list?

# TODO check if file is already there before `pull`ing
for file in $images1 $images2 $images3 $images4 $videos
do
  adb pull -a "$file" "$target"
done

