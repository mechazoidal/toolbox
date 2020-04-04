#!/usr/bin/env sh
# Recombine BMP frames into MP4 (using H.264)

set -o nounset
set -o pipefail
IFS=$'\n\t'

INDIR=${1?Dir of frames is required}
OUTFILE=${2:-}

if [[ -z "$OUTFILE" ]]; then
  OUTFILE="output.mp4"
fi
indir_arg="$INDIR"/'*.bmp'
#echo "$indir_arg"
#'$INDIR/*.bmp'
ffmpeg -v warning -f image2 -pattern_type glob -i "$indir_arg" -lavfi "fps=10" -c:v libx264 "$OUTFILE"
