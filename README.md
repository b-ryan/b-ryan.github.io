.venv/bin/pelican --debug --autoreload -t theme/ -o output/ -s pelicanconf.py content/
cd output && ../.venv/bin/python -m pelican.server 8080
