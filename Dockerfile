FROM python:3.9-buster@sha256:3ac142a26a4313531f25e32926e2ecdf4d75e75a6cbc9164d8343b0971dccf66

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]