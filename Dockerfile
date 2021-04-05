FROM python:3.9-buster@sha256:6eee0ff007028527f0ca9914aa9a0540cf3c9b6e7d066d11e90fba485fd96485

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]