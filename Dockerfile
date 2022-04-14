FROM python:3.10-buster@sha256:6ac45fd31e6f98daddc534fb66b36bbafbd48a808b69cbdb2f791fc3f50e0f69

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]