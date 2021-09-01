FROM python:3.9-buster@sha256:7ce853142a103c166a9a18ac9dbac3891c1114357610343543c4d7519cee0b2c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]