FROM python:3.9-buster@sha256:d34eff2d65a02917eed1e357b21a5503953b369d6f4cde46234a2130c1dc02d6

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]