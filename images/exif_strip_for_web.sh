#!/usr/bin/env sh
# FIXME not always the same name
TOOL="exiftool-5.26"
IMAGE=${1?image file required}
"$TOOL" -all= --icc_profile:all "$IMAGE"

