FROM python:3.9-buster@sha256:faf01e3f23b353ee399398a49e2040debb2528f5fcba6c93dd3caab0bd02ce4f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]