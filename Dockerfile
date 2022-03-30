FROM python:3.10-buster@sha256:4a525abb01828a7a70396ea3835d37a9b869f732bdb82dee330e66779bacbe60

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]