FROM python:3.8-buster@sha256:522db3e2f0ecfec4260c05c25b4ef6c2faff5138f311f3f4202ea29d9f2e2de6

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]