# gunicorn.conf.py

# Basic configuration
bind = "0.0.0.0:5000"
reload = False

# Optional configuration
workers = 4
threads = 2
timeout = 30

# WSGI application to load
wsgi_app = "main:app"
