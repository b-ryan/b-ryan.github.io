#!/bin/bash
if [[ $(git status --short | egrep -v '^\?\?' | wc -l) -gt 0 ]]; then
    echo "Git status is dirty. You must have a clean git to deploy." >&2
    exit 1
fi

commit="$(git rev-parse HEAD)"
echo "deploying $commit"

output_dir=/tmp/output

echo "Compiling to $output_dir"
pelican -t theme -o $output_dir -s publishconf.py content

echo "Committing to gh-pages branch"
git checkout gh-pages
git clean -df
git clean -Xf
git rm -r .
git reset --
rsync -r $output_dir/ .
git add -A .

rm -r $output_dir
