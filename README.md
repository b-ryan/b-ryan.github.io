pelican --debug --autoreload -t theme/ -o output/ -s pelicanconf.py content/
cd output && python -m pelican.server 8080
