FROM python:3.10-buster@sha256:4359fdaccc9adf6d348247ca0445def45cbcf3ec525cd619feea5bb57a87d452

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]