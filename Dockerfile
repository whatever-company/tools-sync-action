FROM python:3.10-buster@sha256:505b5b3babfafd9b7997c95ed5abae6bbfff745e6f019b47287fe9e197ded024

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]