FROM python:3.9-buster@sha256:b372357f943822d5c53035d18d699a7e26d02f8699cbf70c41258d2f7e848abf

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]