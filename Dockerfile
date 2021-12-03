FROM python:3.10-buster@sha256:d55a692ff0675c0fe14cfd4e35a14df72d108e0eaad018f485456d9275a90875

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]