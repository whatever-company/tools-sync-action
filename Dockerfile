FROM python:3.10-buster@sha256:3be6af375f4a1e1f0378694bcf3ec608a56cd378158fe6e6572039cac3faab1f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]