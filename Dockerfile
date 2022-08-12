FROM python:3.10-buster@sha256:ad6194844cade5e3d5220a6dc2bdb0e7983027ee96a92425884327225d4fafd2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]