FROM python:3.10-buster@sha256:ab701d3b43ebabc8c909eadf3b904baf6d5b0b318cf8ce7d995f8f1d8dbc48da

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]