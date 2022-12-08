FROM python:3.11-buster@sha256:d51c0d6bc9458b4e6391746997dd2b5a1d1fd9160282bf1a57ffe4f6d4993f6d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]