#!/bin/bash
set -eu
if [[ -d output ]]; then
    rm -r output
fi
mkdir output
trap 'kill %1' SIGINT
( cd output; python -m pelican.server 5000) &
pelican --debug --autoreload -t theme/ -o output/ -s pelicanconf.py content/
