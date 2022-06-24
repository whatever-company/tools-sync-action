FROM python:3.10-buster@sha256:9ac181aeef2fb2a1b80b5572cfd57620863d8e4f172d5eb7ee17c2b941b0392c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]