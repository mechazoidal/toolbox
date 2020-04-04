#!/usr/bin/env sh
# FIXME not always the same name
TOOL="exiftool-5.26"
IMAGE=${1?image file required}

#may need to use `-xmp-exif:all=` in some cases
"$TOOL" -gps:all= -xmp:geotag= "$IMAGE"
