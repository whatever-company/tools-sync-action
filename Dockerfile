FROM python:3.10-buster@sha256:71568c9d50183ac4682a38f9d29d71c66c528172f0312c6f31319a822d6a0fa5

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]