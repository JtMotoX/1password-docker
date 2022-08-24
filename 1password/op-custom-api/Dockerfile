FROM python:3.10-alpine

COPY ./app/requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt
COPY ./app /app

USER 999:999

CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "--reload", "app.wsgi:app" ]
