FROM python:3.9-buster@sha256:930b08828487ab801fb16f32f043597011c0702ffd0e37aa7f4675127b05758d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]