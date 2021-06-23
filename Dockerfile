FROM python:3.9-buster@sha256:d6486f3063b0d42033bd85792177c5ecd28a767df5075be25ffe23fd3a1aac6f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]