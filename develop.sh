(
  mkdir output
  cd output
  ../.venv/bin/python -m pelican.server 8080
) &
.venv/bin/pelican --debug --autoreload -t theme/ -o output/ -s pelicanconf.py content/
