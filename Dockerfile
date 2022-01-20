FROM python:3.10-buster@sha256:dff69d84da8029266627b47d3f815d189de7179bc921c796b5a4d14302a795b4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]