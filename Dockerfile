FROM python:3.9-buster@sha256:d6e9ef78d912d0a71bd4b3eee99bb51518d971d3017f45e38f5974586c7acc5d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]