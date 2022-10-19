FROM python:3.10-slim

ENV PYTHONUNBUFFERED 1

COPY requirements.txt .
RUN apt update \
    && apt install --yes curl gcc \
    && pip install -U pip \
    && pip install -r ../requirements.txt

WORKDIR /app/bug
COPY . /app

HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

ENTRYPOINT uwsgi --http-socket=:8000 --log-5xx --disable-logging --module=bug.wsgi
