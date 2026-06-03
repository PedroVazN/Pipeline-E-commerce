#!/bin/sh
set -eu

LABEL="${INSTANCE_LABEL:-web-srv-01}"
HTML="/usr/share/nginx/html/index.html"

sed -i "s/const INSTANCE_LABEL = \"[^\"]*\"/const INSTANCE_LABEL = \"${LABEL}\"/" "$HTML"
sed -i "s/<span class=\"badge\" id=\"host\">[^<]*<\/span>/<span class=\"badge\" id=\"host\">${LABEL}<\/span>/" "$HTML"

exec "$@"
