#!/bin/sh

# Directly referencing these variables now because docker-compose sucks
#chown -R abc:abc /app
s6-setuidgid root python3 setup.py --appname $APPNAME --username $ADMINUSER --password $PASSWORD
s6-setuidgid root gunicorn --workers 4 --threads 4 --bind 0.0.0.0:8080 wsgi:app
