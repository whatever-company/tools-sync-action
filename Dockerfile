FROM python:3.10-buster@sha256:af2be7bdb73facb77e143965f49901c2760e93049bcfb750323c0733cc6528bc

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]