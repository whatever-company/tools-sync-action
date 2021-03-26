FROM python:3.9-buster@sha256:bde0b86b12ddadbcd10fd421fb9dfff7259f6eb3940a07c54581d2494c6f0a85

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]