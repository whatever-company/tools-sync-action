FROM python:3.8-buster@sha256:0de2f435ade38d49d15ef0f6b36229b8688510f95f4dcaafd09b15afb24125ad

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]