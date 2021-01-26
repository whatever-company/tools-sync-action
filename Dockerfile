FROM python:3.9-buster@sha256:6882e6645fceebe81c60868ff32a8771d13b0e3dbd005085f5639bbcd7f94db7

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]