FROM python:3.10-buster@sha256:06855bf10251c2ff6a962c3350bbb70e40f519227d03bf1f198c7bb04b56ed91

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]