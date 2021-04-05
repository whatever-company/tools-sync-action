FROM python:3.9-buster@sha256:4e4f9705141005598081207dd9f853e47fccc7edc409659edf816a11b0f11b2f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]