FROM python:3.10-buster@sha256:38fe9126e04a2056c48bc7a64031b40b7b0ba3719c69121fd448c7ccf32f428f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]