FROM python:3.9-buster@sha256:7b319821f54ee42908bd78088799ce7a6e290c150976791d28afd0b683f0c07d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]