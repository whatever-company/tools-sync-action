FROM python:3.10-buster@sha256:4d5e8e23842bdaaa1c568c0b0597f1b6a2ab5341bf37e553a42e02a9643025dd

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]