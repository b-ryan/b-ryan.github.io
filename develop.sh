mkdir output
(
  cd output
  python -m pelican.server 8080
) &
pelican --debug --autoreload -t theme2 -o output -s pelicanconf.py content
