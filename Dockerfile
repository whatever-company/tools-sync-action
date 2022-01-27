FROM python:3.10-buster@sha256:8c325c76ed81d72ced14d936bfb4c4a93473b1cb7dcf8a7f809f08aee97ff342

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]