FROM python:3.9-buster@sha256:d066d957b503bb82765f6eefe51592f001f86181f4cb4557e4332ddeecf19330

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]