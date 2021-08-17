FROM python:3.9-buster@sha256:16d7f07bfcf2435768e04ca198d53434379edb449d4408b8104085ea297b02cf

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]