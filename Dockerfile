FROM python:3.9-buster@sha256:79a631c93960c5919f27f3403e734ec19b130008370a5f902141bcff2e6d6f4c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]