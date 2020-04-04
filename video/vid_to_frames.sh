#!/usr/bin/env sh
# Split video into BMP files

set -o nounset
set -o pipefail
IFS=$'\n\t'

INFILE=${1?Video is required}
OUTDIR=${2:-}
INFILE_BASE=${INFILE%.*}

if [[ -z "$OUTDIR" ]]; then
  OUTDIR="."
fi

ffmpeg -v warning -i "$INFILE" "$OUTDIR"/"$INFILE_BASE"_"%03d.bmp"

#ffmpeg -f image2 -pattern_type glob -i '$TEMPDIR/*.bmp' -c:v libx264 output.mp4
