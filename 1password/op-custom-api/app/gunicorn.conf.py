# gunicorn.conf.py

# Basic configuration
bind = "0.0.0.0:5000"
reload = False

# WSGI application to load
wsgi_app = "main:app"
