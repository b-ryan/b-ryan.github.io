mkdir output
(
  cd output
  python -m pelican.server 5000
) &
pelican --debug --autoreload -t theme/ -o output/ -s pelicanconf.py content/
