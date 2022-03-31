FROM python:3.10-buster@sha256:9821fee17ad3b6057389fccf2a3336bba6ef5cae085e01c94556efa77da38476

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]