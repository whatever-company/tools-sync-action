FROM python:3.10-buster@sha256:007c3be968d7594d41cfa86ce9be807bb1ae15aebeb62ddf7353ae1de947fbf3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]