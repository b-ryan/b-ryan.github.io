#!/bin/bash
if [[ $(git status --short | wc -l) -gt 0 ]]; then
    echo "Git status is dirty. You must have a clean git to deploy." >&2
    exit 1
fi

commit="$(git rev-parse HEAD)"
echo "deploying $commit"

output_dir=/tmp/output

echo "Compiling to $output_dir" >&2
pelican -t theme -o $output_dir -s publishconf.py content || {
    echo "Compilation failed" >&2
    exit 1
}

echo 'blog.buckryan.com' > $output_dir/CNAME

echo "Committing to master branch"
git checkout master
git clean -df
git clean -Xf
git rm -r .
git reset --
rsync -r $output_dir/ .
git add -A .
git commit -m "Publishing $commit"
git push
git checkout -

rm -r $output_dir
