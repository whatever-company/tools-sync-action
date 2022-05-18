FROM python:3.10-buster@sha256:a9c483ecf4dba190acd83d8d036fc51bd28297ece953bc0d2cc4547389680d70

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]