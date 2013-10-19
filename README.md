pelican --debug --autoreload -o output/ -s pelicanconf.py content/
cd output && python -m pelican.server 8080
