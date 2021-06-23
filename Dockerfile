FROM python:3.9-buster@sha256:526050dbe89d90acefaa4899480b4a20e83e6603f7ec4ee1aeeb9193d35dd3cf

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]