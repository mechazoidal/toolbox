#!/usr/bin/env sh

# ex usage: pinboard/dead_links.sh download.xml | grep "^Tweet from" | cut -d$'\037' -f 2 > tweet_from_links.txt
# (where download.xml is a export from pinboard settings backup page)
# requires: curl, xmlstarlet, gnu parallel
set -o nounset
set -o pipefail
IFS=$'\n\t'

INFILE=${1:-}
TEMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/pinboard.XXXXXXX")
function finish {
  rm -rf "$TEMPDIR"
}
trap finish exit


UNREAD_POSTS="$TEMPDIR"/unread.xml
echo '<?xml version="1.0" encoding="UTF-8"?><posts user="user">' > "$UNREAD_POSTS"
xmlstarlet sel -t -c '//posts/post[@toread="yes"]' "$INFILE" >> "$UNREAD_POSTS"
echo '</posts>' >> "$UNREAD_POSTS"

# split unread posts into two separate files. since xmlstarlet always reads the file in order, the two files can then be combined via paste(1)
POST_HREFS="$TEMPDIR"/unread-hrefs
POST_DESCS="$TEMPDIR"/unread-descs
xmlstarlet sel -t -v '//post/@href' "$UNREAD_POSTS" > "$POST_HREFS"
xmlstarlet sel -t -v '//post/@description' "$UNREAD_POSTS" > "$POST_DESCS"
FIELD_SEPARATOR=$'\037'
POST_LINKS="$TEMPDIR"/unread_links
paste -d"$FIELD_SEPARATOR" "$POST_DESCS" "$POST_HREFS" > "$POST_LINKS"


# TODO take param to output to file, to be able to use --progress in parallel
#POST_RESULTS="$TEMPDIR"/unread_links_status
#--progress
<"$POST_LINKS" parallel  "curl -o /dev/null --silent --connect-timeout 10 --max-time 30 --head --location --write-out '%{http_code} %{url_effective} ' {}; echo {}" 
#> "$POST_RESULTS"
