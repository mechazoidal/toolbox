#!/usr/bin/env sh
# Convert a MP4 file to a GIF
# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html#usage
# usage: vid_to_gif.sh infile.mp4 [infile.gif] [320:-1]
# size is a ffmpeg size string

set -o nounset
set -o pipefail
IFS=$'\n\t'

INFILE=${1?Video is required}
OUTFILE=${2:-}
SIZE=${3:-}

if [[ -z "$OUTFILE" ]]; then
  OUTFILE="$INFILE".gif
fi

TEMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/vid_to_gif.XXXXXXX")
function finish {
  rm -rf "$TEMPDIR"
}
trap finish exit

palette="$TEMPDIR/palette.png"
# filters="fps=15,scale=320:-1:flags=lanczos"
filters="fps=15"
if [[ -n "$SIZE" ]]; then
  filters="$filters,scale=$SIZE"
fi

ffmpeg -v warning -i "$INFILE" -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i "$INFILE" -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y "$OUTFILE"
