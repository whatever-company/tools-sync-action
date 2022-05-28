FROM python:3.10-buster@sha256:aa70c1f05ee54945b101ccaac0a54bc797dc5e1ff8b9e7f6f5a40597b32071f3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]