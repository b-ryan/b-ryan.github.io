#!/bin/bash
set -eu
if [[ -d development ]]; then
    rm -r development
fi
mkdir development
trap 'kill %1' SIGINT
( cd development; python -m pelican.server 5000) &
pelican --debug --autoreload \
    -t theme/ \
    -o development/ \
    -s pelicanconf.py \
    content/
