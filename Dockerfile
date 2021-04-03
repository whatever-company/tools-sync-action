FROM python:3.9-buster@sha256:926b737b9f7064282e6e3eb8168b3a2c881971a92ed72a14e2ff95a15971f057

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]